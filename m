From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 02 Dec 2014 20:35:11 -0800 (PST)
Message-ID: <20141202.203511.1346917579566370675.davem@davemloft.net>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
	<20141202.192311.1226452173523245977.davem@davemloft.net>
	<5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaLCEat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 23:30:49 -0500
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Du, Fan" <fan.du@intel.com>
Date: Wed, 3 Dec 2014 03:32:46 +0000

>>If guest sees a 1500 byte MTU, that's it's link layer MTU and it had better be able to
>>send 1500 byte packets onto the "wire".
> 
> This patch makes it happens exactly as you putted.
> 
>>If you cannot properly propagate the vxlan encapsulation overhead back into the
>>guest's MTU you must hide this problem from the rest of our stack somehow.
> 
> Again, this patch hide this problem to make Guest feel it can send packet with MTU as 1500 bytes.

I said make the guest see the real MTU, not hide the real MTU by
fragmenting or spitting ICMP PMTU messages back.
