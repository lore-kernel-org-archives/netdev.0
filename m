From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 04:50:21 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEE0DC@SHSMSX104.ccr.corp.intel.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
	<20141202.192311.1226452173523245977.davem@davemloft.net>
	<5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
 <20141202.203511.1346917579566370675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>, "Du, Fan" <fan.du@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:5548 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaLCEu0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 23:50:26 -0500
In-Reply-To: <20141202.203511.1346917579566370675.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, December 3, 2014 12:35 PM
>To: Du, Fan
>Cc: netdev@vger.kernel.org; fw@strlen.de
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>From: "Du, Fan" <fan.du@intel.com>
>Date: Wed, 3 Dec 2014 03:32:46 +0000
>
>>>If guest sees a 1500 byte MTU, that's it's link layer MTU and it had
>>>better be able to send 1500 byte packets onto the "wire".
>>
>> This patch makes it happens exactly as you putted.
>>
>>>If you cannot properly propagate the vxlan encapsulation overhead back
>>>into the guest's MTU you must hide this problem from the rest of our stack
>somehow.
>>
>> Again, this patch hide this problem to make Guest feel it can send packet with
>MTU as 1500 bytes.
>
>I said make the guest see the real MTU, not hide the real MTU by fragmenting or
>spitting ICMP PMTU messages back.

Do you have any better idea to achieve what you said besides this patch approach
without both fragmentation and ICMP message at the same time to cater for all kinds
tunnel tech?
