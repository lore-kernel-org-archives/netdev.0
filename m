From: Anders Berggren <anders@halon.se>
Subject: Re: [E1000-devel] [PATCH] fixing hw timestamping in igb
Date: Tue, 8 Feb 2011 16:25:04 +0100
Message-ID: <331E9D4A-6738-405A-8457-14858D1072DA@halon.se>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se> <1296775407.2698.10.camel@jtkirshe-MOBL1>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp.halon.se ([212.37.18.222]:51923 "EHLO vsp.halon.se"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754835Ab1BHPZJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 10:25:09 -0500
In-Reply-To: <1296775407.2698.10.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 4, 2011, at 12:23 AM, Jeff Kirsher wrote:

> Thanks Anders, I will add this patch to my queue of igb patches.

Another question which I asked John Ronciak earlier; is there any work on TX timestamping for IPv6? In 2.6.37 sock_tx_timestamp() is only called in IPv4 UDP (net/ipv4/udp.c) and raw sockets (net/packet/af_packet.c).

Would it be meaningful if I tried to add it to ipv6/ip6_output.c as Marcus D. Leech suggested in http://kerneltrap.org/mailarchive/linux-netdev/2009/11/10/6260604 and http://kerneltrap.org/mailarchive/linux-netdev/2009/11/11/6260643 