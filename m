From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC 0/6] Gigaset driver port to CAPI
Date: Fri, 21 Aug 2009 19:21:34 +0200 (CEST)
Message-ID: <20090821-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:50988 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932644AbZHURVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 13:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

the following set of six patches adds a configuration option to the
Gigaset driver to interface to Kernel CAPI instead of the old
ISDN4Linux subsystem. Although my unit test are not quite done yet
I would appreciate comments.

The patchset is based on 2.6.31-rc6. The first two patches are
bugfixes to the existing driver, the third one adds kerneldoc
comments for a few functions. These three are included just so
that the following ones will apply cleanly, although you are
welcome to comment on them, too.

Patch 4 reorganizes the existing driver's code so that the new
interface can be fitted in.

Patch 5 adds the Kconfig mechanism for making the ISDN subsystem
interface selectable.

Patch 6 finally adds the actual Kernel CAPI interface, and is of
course the one I am most eager to hear opinions about.

Thanks,
Tilman
