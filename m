From: Andreas Jaggi <aj@open.ch>
Subject: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 1 Sep 2009 11:29:10 +0200
Message-ID: <20090901092910.GC11354@urbino.open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jing Min Zhao <zhaojingmin@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:63040 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401AbZIAJsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 05:48:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi

In a scenario where videoconferencing traffic is going through a Linux gateway/firewall, we are having some troubles with the nf_conntrack_h323 moduledropping packets.
The videoconferencing devices use version 10 of the H.245 protocol, but nf_conntrack_h323 supports version 7 (according to the comments in include/linux/nf_conntrack_h323.h).

Are there any plans to include support for version 10 (or higher) of H.245 in nf_conntrack_h323?

Thanks,
Andreas
