From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/2] Fixes for errors reported by 0day on net-next tree
Date: Mon,  3 Jul 2017 14:50:26 +0300
Message-ID: <1499082628-21253-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Despite the fact that we have automatic testing enabled
on all our branches, there s390-config related errors got through.
I will investigate separately why it happened.
Sorry for the inconvince and please pull.

Elena Reshetova (2):
  net, iucv: fixing error from refcount conversion
  drivers, s390: fix errors resulting from refcount conversions

 drivers/s390/net/ctcm_fsms.c | 12 ++++++------
 net/iucv/af_iucv.c           |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

-- 
2.7.4
