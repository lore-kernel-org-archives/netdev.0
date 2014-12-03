From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 06:53:08 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEE22D@SHSMSX104.ccr.corp.intel.com>
References: <5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
	<20141202.203511.1346917579566370675.davem@davemloft.net>
	<5A90DA2E42F8AE43BC4A093BF0678848DEE0DC@SHSMSX104.ccr.corp.intel.com>
 <20141202.211449.2074426768363313524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>, "Du, Fan" <fan.du@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25840 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbaLCGz5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 01:55:57 -0500
In-Reply-To: <20141202.211449.2074426768363313524.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, December 3, 2014 1:15 PM
>To: Du, Fan
>Cc: netdev@vger.kernel.org; fw@strlen.de
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>From: "Du, Fan" <fan.du@intel.com>
>Date: Wed, 3 Dec 2014 04:50:21 +0000
>
>> Do you have any better idea to achieve what you said besides this
>> patch approach without both fragmentation and ICMP message at the same
>> time to cater for all kinds tunnel tech?
>
>I am not obligated to figure out for you how to design a correctly implemented
>patch.
>
>But I am obligated to keep a bad change from going into the tree and that is what I
>am doing.

"bad" is not depending whether you say it or not, but what the real world needs and what
proper solution could be provided at the time being.
