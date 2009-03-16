From: Felix von Leitner <felix-kernel@fefe.de>
Subject: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 00:48:10 +0100
Message-ID: <20090316233934.GD32111@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:34174 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751088AbZCPXyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 19:54:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's an strace:

socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(3, {sa_family=AF_INET6, sin6_port=htons(6969), inet_pton(AF_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)

This is supposed to work, and it works on other operating systems, even
on Mac OS X.

I think it used to work on Linux, too.

I'm using 2.6.29-rc7 right now, but others have reported this not
working on distro kernels, too.

Felix
