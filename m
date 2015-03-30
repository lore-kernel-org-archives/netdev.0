From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/7] drivers: Use bool function return values true/false not 1/0
Date: Mon, 30 Mar 2015 10:43:16 -0700
Message-ID: <cover.1427736972.git.joe@perches.com>
Cc: dri-devel@lists.freedesktop.org
To: linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	linux-raid@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	netdev@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-serial@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (7):
  drm: Use bool function return values of true/false not 1/0
  dm_table: Use bool function return values of true/false not 1/0
  genwqe: Use bool function return values of true/false not 1/0
  wmi: Use bool function return values of true/false not 1/0
  ssb: Use bool function return values of true/false not 1/0
  thermal: Use bool function return values of true/false not 1/0
  serial: kgdb_nmi: Use bool function return values of true/false not
    1/0

 drivers/gpu/drm/ast/ast_post.c        |  2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_fence.c |  2 +-
 drivers/md/dm-table.c                 | 20 ++++++++++----------
 drivers/misc/genwqe/card_base.h       |  2 +-
 drivers/platform/x86/wmi.c            |  4 ++--
 drivers/ssb/driver_gige.c             |  2 +-
 drivers/thermal/thermal_core.h        |  2 +-
 drivers/tty/serial/kgdb_nmi.c         |  6 +++---
 8 files changed, 20 insertions(+), 20 deletions(-)

-- 
2.1.2
