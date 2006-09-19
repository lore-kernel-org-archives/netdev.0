From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 18/23] e1000: revert 'e1000: Remove 0x1000 as supported device'
Date: Tue, 19 Sep 2006 10:29:13 -0700
Message-ID: <20060919172913.4605.84224.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:28941 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030353AbWISRUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:19 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The commit 'e1000: Remove 0x1000 as supported device' (Jeff Kirsher,
673a052fde79ab5e9dce569b0336358812ddba2d) Removes PIC device ID 8086:1000
from the list of supported devices. A fix was submitted for the original
issue (commit 6a9516989f94df10d9a27ba543c6b53b3e69c84a).

This commit reverts commit 673a052fde79ab5e9dce569b0336358812ddba2d and
re-enables 82542rev3 chips completely.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 0 files changed, 0 insertions(+), 0 deletions(-)




---
Auke Kok <auke-jan.h.kok@intel.com>
