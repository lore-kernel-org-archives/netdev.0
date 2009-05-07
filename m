From: David Madore <david+ml@madore.org>
Subject: MTU blackhole discovery for IPv6 ?
Date: Thu, 7 May 2009 23:19:26 +0200
Message-ID: <20090507211926.GA28662@regulus.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NetDev Mailing-List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regulus.xn--kwg.net ([212.85.152.99]:58990 "EHLO
	regulus.xn--kwg.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbZEGV0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:26:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There's a sysctl called net.ipv4.tcp_mtu_probing: has there been any
work done on the analogous key for IPv6?

I'm encountering a number of asinine network providers who either
discard ICMPs (whether v4 or v6...) or simply don't emit them.  The
IPv6 picture is even bleaker than IPv4 because so much traffic goes
through tunnels like 6to4.  An IPv6 MTU blackhole discovery
implementation would truly save my day.

I understand that RFC 4821 specifies the same algorithms for
packetization layer path MTU discovery in IPv4 and IPv6.  Did Linux
implement this in IPv4 only because there is some difficulty in doing
the same thing for IPv6, or simply because nobody was asking for it?

Happy hacking,

--
     David A. Madore
   ( http://www.madore.org/~david/ )
