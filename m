From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sat, 09 Feb 2013 23:12:46 +0900
Message-ID: <5116595E.2080601@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@wide.ad.jp>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:55526 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757261Ab3BIOMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 09:12:48 -0500
In-Reply-To: <20130209121005.GB23281@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hannes Frederic Sowa wrote:
> On Wed, Feb 06, 2013 at 05:54:15PM +0100, Hannes Frederic Sowa wrote:
>> On Thu, Feb 07, 2013 at 12:24:14AM +0900, YOSHIFUJI Hideaki wrote:
>>> NAK.  I think we should select routes via loopback device here.
>>
>> Will try your idea, thanks.
> 
> Does this patch look reasonable? Btw. i am pleased to see this kind of
> things work out as expected most of the time (addrtype checking etc. all
> in place). :)
> 

Well, I rethink of what "interface-local" means.

It seems applications will join ff01::/16%eth0 instead of ff01::/16%lo.
If so, your original patch seems better.  My bad, sorry.

Would you update original one, with minor modification that defers
kfree_skb() after incrementing MIB, please?

If you think we should join ff01::{1,2} by default, you can send another
patch for it.  (BTW, why don't we join ff05::2, then? ;-))

Thanks.

--yoshfuji
