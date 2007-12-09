From: Michael Blizek <michi1@michaelblizek.homelinux.net>
Subject: [RFC] Connection Oriented Routing Protocol
Date: Sun, 9 Dec 2007 11:20:46 +0100
Message-ID: <20071209102046.GA1228@grml.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from michaelblizek.homelinux.net ([193.238.157.55]:56245 "EHLO
	michaelblizek.homelinux.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751976AbXLIKY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 05:24:59 -0500
Received: from [127.0.0.1] (helo=127.0.0.1)
	by michaelblizek.homelinux.net with smtp (Exim 4.63)
	(envelope-from <michi1@michaelblizek.homelinux.net>)
	id 1J1JLH-0000kX-By
	for netdev@vger.kernel.org; Sun, 09 Dec 2007 11:24:59 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm programming a new layer 3+4 protocol. It does not
have a routing table for every destination. Instead the
end node established a connection through every router
to the destination. This allows some pretty interesting
optimisations. See

http://michaelblizek.homelinux.net/projects/cor/index.html

for more details. You can download it with this link:

http://michaelblizek.homelinux.net/projects/cor/downloads/cor_2007_12_09.diff

This is a pretty early version. It does compile, but it
will not run. I can post is on this list, if you want to.
It applies to 2.6.22.2 (sorry), but the only files which
are touched outside the new net/cor directory are
net/Kconfig and net/Makefile

	-Michi

