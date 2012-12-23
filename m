From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Mon, 24 Dec 2012 04:38:40 +0900
Message-ID: <50D75DC0.4030902@linux-ipv6.org>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org> <50D6E73F.70301@gmail.com> <50D6F488.7060308@linux-ipv6.org> <50D7062D.8040901@gmail.com> <50D73ABB.4020800@linux-ipv6.org> <50D74C81.1000400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	stefanr@s5r6.in-berlin.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36230 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751922Ab2LWTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 14:38:42 -0500
In-Reply-To: <50D74C81.1000400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:

> I believe the the changes in the transmit portions for ndisc are rather simple. All firewire specific information is stored in the private data of struct net_device. For the receive section I think I have to change something in ndisc_recv_ns(), I'll figure that out. Maybe I need some (small) support from you, but I think we can do that off list.
> 
> I'll try it out but after Christmas. :)
> 
> But I have to emphasize that I really need (read) access to the firewire specific portions of the link layer option in the firewire net driver. That _is_ necessary to build the relation between the firewire hardware address (GUID) and the corresponding firewire node.

If you change the "hardware address length", you can get
notification when you have new neighbor.
Even if you did not change that, you could introduce new
netevent notification.

> Because you mentioned IPSEC: Are the ndisc packets also encrypted? If so, I just can't imagine how I can do the mapping of firewire hardware addresses and firewire nodes.

I don't think we will see encrypted ND messages, but
IP layer should handle encrypted NDISC messages.

--yoshfuji
