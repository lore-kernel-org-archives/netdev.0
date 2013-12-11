From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v4 0/2] napi fixes
Date: Wed, 11 Dec 2013 10:57:14 +0000
Message-ID: <1386759436-46737-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43921 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab3LKK5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 05:57:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This 2 patch series is essentially v4 of "xen-netback: fix abuse of napi
budget".

v4:
- Add missing 'Reported-by' to patch 2 comment
- Add explanation of where the ring event pointer is update to patch 2
  comment

v3:
- Break into two patches
- Don't lose the work_to_do value in xenvif_build_tx_gops

v2:
- More elaborate description of the problem and the fix in the comment.
- Modified the check in xenvif_build_tx_gops.
