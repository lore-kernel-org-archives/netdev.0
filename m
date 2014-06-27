From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH] README: clarify redistribution requirements covering patents
Date: Fri, 27 Jun 2014 12:39:27 -0700
Message-ID: <1403897967-5894-1-git-send-email-mcgrof@do-not-panic.com>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-firmware@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:45488 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaF0Tji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 15:39:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Firmware licenses on linux-firmware should include an implicit
or explicit patent grant to end users for full device operation
otherwise it would start making linux-firmware useless for many
Linux distributions which have positions against patent encumbered
software [0] [1] [2] and it would mean cherry picking firmware files
out. It can also mean making it problematic to redistribute linux-firmware
in some jurisdictions which could have different positions on
patents, or have already outlawed software patents.

Licenses with implicit patent grants are allowed given that otherwise
we couldn't carry permissively licensed firmwares which would be silly,
but using permissively licensed firmware files which remove patent
grants explicitly are not allowed.

A clarifications is needed as one attempt was already made to include
firmware encumbered by patents without a grant [3] and it was decided
we would not allow these. We clarify this to make this requirement
explicit and prevent these type of further attempts.

[0] https://www.debian.org/legal/patent
[1] http://fedoraproject.org/wiki/Software_Patents#Red_Hat.27s_position_on_Software_Patents
[2] http://www.openinventionnetwork.com/about-us/
[3] https://lkml.org/lkml/2014/3/14/182

Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---

This wasn't clear and at one point one entity already tried to get
included a firmware that explicitly removes any patent grants for
users.

 README | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/README b/README
index f2ed92e..d2a56ec 100644
--- a/README
+++ b/README
@@ -18,7 +18,10 @@ and also cc: to related mailing lists.
 
 Your commit should include an update to the WHENCE file clearly
 identifying the licence under which the firmware is available, and
-that it is redistributable. If the licence is long and involved, it's
+that it is redistributable. Being redistributable includes ensuring
+the firmware license provided includes an implicit or explicit
+patent grant to end users to ensure full functionality of device
+operation with the firmware. If the licence is long and involved, it's
 permitted to include it in a separate file and refer to it from the
 WHENCE file.
 And if it were possible, a changelog of the firmware itself.
-- 
2.0.0
