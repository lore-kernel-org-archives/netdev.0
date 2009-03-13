From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict
 verification
Date: Fri, 13 Mar 2009 16:02:58 -0700 (PDT)
Message-ID: <20090313.160258.151176507.davem@davemloft.net>
References: <200903011344.45814.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbZCMXDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:03:12 -0400
In-Reply-To: <200903011344.45814.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryschenko <denys@visp.net.lb>
Date: Sun, 1 Mar 2009 13:44:45 +0200

> Windows (XP at least) hosts on boot, with configured static ip, performing 
> address conflict detection, which is defined in RFC3927.
> Here is quote of important information:
> 
> "
> An ARP announcement is identical to the ARP Probe described above, 
> except    that now the sender and target IP addresses are both set 
> to the host's newly selected IPv4 address. 
> "
> 
> But it same time this goes wrong with RFC5227.
> "
> The 'sender IP address' field MUST be set to all zeroes; this is to avoid
> polluting ARP caches in other hosts on the same link in the case
> where the address turns out to be already in use by another host.
> "
> 
> When ARP proxy configured, it must not answer to both cases, because 
> it is address conflict verification in any case. For Windows it is just 
> causing to detect false "ip conflict". Already there is code for RFC5227, so 
> just trivially we just check also if source ip == target ip.
> 
> Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>

Patch applied to net-next-2.6

Although, It's a shame that I had to munge such a simple patch so
much, between the bad comment formatting and the trailing whitespace
characters.

Please be mindful of this in future patch submissions.

Thanks.
