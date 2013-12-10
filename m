From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v3 0/2] xen-netback: napi fixes
Date: Tue, 10 Dec 2013 13:39:40 +0000
Message-ID: <1386682782-7052-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27072 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab3LJNjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 08:39:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This 2 patch series is essentially v3 of "xen-netback: fix abuse of napi
budget".

v3:
- Break into two patches
- Don't lose the work_to_do value in xenvif_build_tx_gops

v2:
- More elaborate description of the problem and the fix in the comment.
- Modified the check in xenvif_build_tx_gops.
