From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [resend take 1] [0/3] Distributed storage release.
Date: Wed, 5 Nov 2008 19:27:04 +0300
Message-ID: <20081105162704.GA10787@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:39725 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752352AbYKEQ1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 11:27:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am pleased to announce distributed storage (DST) project release,
which is a resend of the previous documentation update one with
whitespace cleanups. As old tradition, this release has the new name.

DST is a block layer network device, which among others has following
features:

 * Kernel-side client and server. No need for any special tools for
	data processing (like special userspace applications) except
	for configuration.
 * Bullet-proof memory allocations via memory pools for all temporary
 	objects (transaction and so on).
 * Zero-copy sending (except header) if supported by device
 	using sendpage().
 * Failover recovery in case of broken link
 	(reconnection if remote node is down).
 * Full transaction support (resending of the failed transactions
 	on timeout of after reconnect to failed node).
 * Dynamically resizeable pool of threads used for data receiving
 	and crypto processing.
 * Initial autoconfiguration. Ability to extend it with additional
 	attributes if needed.
 * Support for any kind of network media (not limited to tcp or inet
 	protocols) higher MAC layer (socket layer). Out of the box
	kernel-side IPv6 support (needs to extend configuration utility,
	check how it was done in POHMELFS [1]).
 * Security attributes for local export nodes (list of allowed to
 	connect addresses with permissions).
 * Ability to use any supported cryptographically strong checksums.
 	Ability to encrypt data channel.
 * Keepalive messages to detect failed nodes early.

One can grab sources (various configuration examples can be found
in 'userspace' dir) from archive, or via kernel and userspace GIT trees.

Consider for inclusion.
Thank you.

1. POHMELFS homepage.
http://www.ioremap.net/projects/pohmelfs

2. DST homepage.
http://www.ioremap.net/projects/dst

3. DST archive.
http://www.ioremap.net/archive/dst/

4. DST git trees.
http://www.ioremap.net/cgi-bin/gitweb.cgi

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

-- 
	Evgeniy Polyakov
