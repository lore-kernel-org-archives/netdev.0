From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/4] isdn: patches for 2.6.31 (v2)
Date: Sun,  7 Jun 2009 21:09:23 +0200 (CEST)
Message-ID: <20090607-patch-00.tilman@imap.cc>
To: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:43715 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbZFGTJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2009 15:09:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, Karsten,

this is the revised version of my patches to the Kernel CAPI subsystem
I'd like to propose for inclusion in kernel release 2.6.31.

The first patch of the series, renaming capi_ctr_reseted() to
capi_ctr_down(), is unchanged.

The patch to drivers/isdn/capi/capiutil.c has been split in two, one
adding the kerneldoc comments and the other one, the NULL pointer
check.

The last patch to Documentation/isdn/INTERFACE.CAPI has grown another
capiutil function description, capi_cmd2str().

Thanks,
Tilman
