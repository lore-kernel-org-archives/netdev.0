From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next 0/4] 6lowpan: set of bug fixes
Date: Mon, 11 Jun 2012 00:37:41 -0400
Message-ID: <20120611003741.27263005@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:52958 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2FKEqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 00:46:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

(This is my first time submitting patches. If I fail to apply to
some rules in here, please let me know)

After reading the 6lowpan code, I found a few issues. This patchset
fixes them. This patchset should apply cleanly against the current
net-next. It contains only bug fixes, I'll send later on a few other
patches that will offer new functionalities.

This is a set of 4 small patches that correct bugs in 6lowpan:
- patch 1 fixes a potential crash when reassembling UDP fragments
- patch 2 fixes a type issues that prevent the fragmentation reassembly
  to operate properly.
- patch 3 and 4 corrects field encoding issues

Hope it helps.

Regards,
	Tony Cheneau
