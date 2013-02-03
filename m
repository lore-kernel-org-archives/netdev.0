From: David Madore <david+ml@madore.org>
Subject: Re: assigning an entire subnet of addresses to an interface
Date: Sun, 3 Feb 2013 23:00:57 +0100
Message-ID: <20130203220057.GA14363@achernar.madore.org>
References: <20130203205124.GA13738@aldebaran.madore.org>
 <DUB107-W70CD0C5839AA44142F48CED020@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lukas Tribus <luky-37@hotmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from achernar.gro-tsen.net ([88.191.144.68]:41900 "EHLO
	achernar.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab3BCWBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 17:01:00 -0500
Content-Disposition: inline
In-Reply-To: <DUB107-W70CD0C5839AA44142F48CED020@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2013 at 10:45:45PM +0100, Lukas Tribus wrote:
> The feature you are looking for is called "Transparent proxy support" or
> TPROXY, and is in the kernel since 2.6.28.
> 
> This allows an application to bind to any address and handle that traffic.

This is indeed, interesting, and I'm glad you pointed out this
possibility, because it had escaped my radar.  (Note that there are
two slightly different things, though: the TPROXY iptables/ip6tables
target which redirects packets to a local socket, and the IP-level
IP_TRANSPARENT socket option which allows a user application to bind
to an arbitrary address.  The latter is closer to what I was asking.)

However, this still does not really answer my question: to bind to
127.1.2.3 one does not need to do a prior setsockopt(fd, SOL_IP,
IP_TRANSPARENT, &1), so the kernel does seem to have a way to say "for
this entire subnet, it will be possible to bind to any address without
doing anything special".

Happy hacking,

-- 
     David A. Madore
   ( http://www.madore.org/~david/ )
