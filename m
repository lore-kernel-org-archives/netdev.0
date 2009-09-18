From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 00/12] Gigaset driver patches for 2.6.32 (v2)
Date: Sat, 19 Sep 2009 01:57:43 +0200 (CEST)
Message-ID: <20090919-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:35047 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbZIRX6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 19:58:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten,

following is the second release of the series of patches I submitted on
2009-09-19 for the Gigaset drivers. I have changed the code formatting
in patches 6, 7, 10, and 12 to elliminate checkpatch warnings. Apart
from that, they are unchanged. According to Dave Miller's response to
my first submission, these should go to you, not him, for merging.
Would you please see to it that they are merged for kernel release
2.6.32?

Patches 01 to 09 provide various small bugfixes, error handling and
documentation improvements for the driver. Their merging for 2.6.32
shouldn't pose any problems.

Patch 10 provides a substantial code reorganization in preparation for
the new CAPI interface, without changing anything in the driver's
functionality. It would obviously make my ongoing work on the driver
much easier if that one would make it into 2.6.32, too.

Patch 11 introduces the Kconfig framework for uncoupling the driver
from isdn4linux. It is rather lightweight and, I hope, uncontroversial.

Patch 12 finally adds the new CAPI interface to the driver. This is
the culmination point of the series and undoubtedly the one that might
benefit the most from your review.

Thanks,
Tilman

