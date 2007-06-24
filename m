From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Scaling Max IP address limitation
Date: Sun, 24 Jun 2007 12:54:49 -0700
Message-ID: <OF73D2E5B5.A62E8708-ON88257304.006BD251-88257304.006D56F9@us.ibm.com>
References: <D6003DDE-0C36-437B-B70A-D422DFE153D0@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@linux-foundation.org>, djones@rossove.com,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:33065 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbXFXTy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 15:54:56 -0400
In-Reply-To: <D6003DDE-0C36-437B-B70A-D422DFE153D0@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> <Unrelated wishful thinking>
> I keep having hopeful dreams that one day netfilter will grow support 
> for cross-protocol NAT (IE: NAT a TCPv4 connection over TCPv6 to the 
> IPv6-only local web server, or vice versa).  It would seem that would 
> require a merged "xtables" program.

        You don't actually need it (at least for easy cases like that),
because IPv6 defines IPv4 mapped IPv6 addresses of the form
::ffff:a.b.c.d. These will generate IPv4 packets for a.b.c.d, from
a v6 socket.
        Unless you're using v6only binding (a sysctl option), you can
connect to v6-only servers using a v4 network and a v4 address of the
server. The peer address on those connections will show up as a v4
mapped address, and all the traffic will be v4, but the socket layer
is all v6.

                                                                +-DLS


