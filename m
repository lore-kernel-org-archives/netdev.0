From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] dynamic_debug
Date: Thu, 30 Jun 2011 11:14:33 -0700
Message-ID: <cover.1309457340.git.joe@perches.com>
References: <20110630163218.GA2457@redhat.com>
Cc: linux-kernel@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110630163218.GA2457@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some improvements and cleanups to dynamic_debug

btw Jason:

You're not listed in MAINTAINERS for dynamic_debug.[ch].
Maybe you should add yourself. 

Joe Perches (4):
  dynamic_debug: Add __dynamic_dev_dbg
  dynamic_debug: Consolidate prefix output to single routine
  dynamic_debug: Remove uses of KERN_CONT in dynamic_emit_prefix
  dynamic_debug: Convert printks to pr_<level>

 drivers/base/core.c           |    5 +-
 include/linux/device.h        |    5 ++
 include/linux/dynamic_debug.h |   10 +++-
 lib/dynamic_debug.c           |  133 +++++++++++++++++++++++++++--------------
 4 files changed, 103 insertions(+), 50 deletions(-)

-- 
1.7.6.rc1
