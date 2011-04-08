From: Sebastian Nickel <Sebastian.Nickel@hetzner.de>
Subject: Re: Kernel panic when using bridge
Date: Fri, 8 Apr 2011 13:49:32 +0000 (UTC)
Message-ID: <loom.20110408T153726-822@post.gmane.org>
References: <4D9E62D9.5010400@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52824 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887Ab1DHOAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 10:00:11 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Q8CEJ-0004lC-QR
	for netdev@vger.kernel.org; Fri, 08 Apr 2011 16:00:07 +0200
Received: from static.34.25.40.188.clients.your-server.de ([188.40.25.34])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 16:00:07 +0200
Received: from Sebastian.Nickel by static.34.25.40.188.clients.your-server.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 16:00:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scot Doyle <lkml <at> scotdoyle.com> writes:

> 
> This kernel panic occurs when using a bridge. I would be grateful for 
> any ideas on how to correct it.
> 
> The panic was captured on two servers after three or four days of 
> minimal use, both configured as follows:
> - unpatched kernel 2.6.39-rc1 (commit 
> ecb78ab6f30106ab72a575a25b1cdfd1633b7ca2) with default .config options
> - br0 on single intel igb NIC (3 other NIC's unused)
> - br0 with ip address on distinct /27 subnet
> - br0:1 with ip address on distinct /24 subnet
> - br0:2 with ip address on distinct /24 subnet
> - no iptables rules
> - ebtables not installed
> 
> "net/bridge/br_netfilter.c" and "net/ipv4/ip_options.c" (in the current 
> 2.6.39-rc2 and in net-next-2.6) are identical to the versions used to 
> build this kernel.
> 

We have the same problems with kernel version 2.6.37.4 (unpatched). Almost same
stacktrace.

After some time there is a kernel panic.

-br0 contains a realtek NIC (8169) and some vnet devices used with KVM.

Any ideas would be great...

