From: Chase Douglas <chase.douglas@canonical.com>
Subject: [PATCH 0/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 10:33:15 -0400
Message-ID: <1268836396-23943-1-git-send-email-chase.douglas@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:39380 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0CQOde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 10:33:34 -0400
Received: from hutte.canonical.com ([91.189.90.181])
	by adelie.canonical.com with esmtp (Exim 4.69 #1 (Debian))
	id 1NruJR-0004UY-0y
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 14:33:33 +0000
Received: from cpe-98-31-46-159.woh.res.rr.com ([98.31.46.159] helo=canonical.com)
	by hutte.canonical.com with esmtpsa (TLS-1.0:DHE_RSA_AES_128_CBC_SHA1:16)
	(Exim 4.69)
	(envelope-from <chase.douglas@canonical.com>)
	id 1NruJQ-0002TH-Op
	for netdev@vger.kernel.org; Wed, 17 Mar 2010 14:33:33 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe an Ubuntu user has found an issue that has been resolved in the -rt
patchset for a few years. I pulled the fix from the patchset and built a test
kernel for the user, but I've yet to hear usable results back (test kernel
isn't booting right, but it may be due to other big changes that went in the
newer Ubuntu kernel I gave him). In the meantime, I'm sending this on for folks
to take a look at. All useful information can be found in the commit message,
including a link to the bug report with a BUG message.

-- Chase

