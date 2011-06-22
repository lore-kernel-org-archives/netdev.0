From: Vitaliy Ivanov <vitalivanov@gmail.com>
Subject: [PATCH] net: wimax: Remove of unused 'rfkill_input' pointer
Date: Wed, 22 Jun 2011 21:06:44 +0300
Message-ID: <1308766004.13761.32.camel@vivanov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alan Jenkins <alan-jenkins@tuffmail.co.uk>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	"John W. Linville" <linville@tuxdriver.com>
To: "David S. Miller" <davem@davemloft.net>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David,

Please apply.

I added here all the peoples who took part in
19d337dff95cbf76edd3ad95c0cee2732c3e1ec5 commit for any comments.

Also performed all yes/no/mod config builds w/ no issues.


>From b93ca8947e85e4ff7e9f314675d4770b90b77548 Mon Sep 17 00:00:00 2001
From: Vitaliy Ivanov <vitalivanov@gmail.com>
Date: Wed, 22 Jun 2011 20:57:49 +0300
Subject: [PATCH] net: wimax: Remove of unused 'rfkill_input' pointer

Seems like this was not cleaned during the 'rfkill: rewrite' checkin
19d337dff95cbf76edd3ad95c0cee2732c3e1ec5.

Signed-off-by: Vitaliy Ivanov <vitalivanov@gmail.com>
---
 include/net/wimax.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/wimax.h b/include/net/wimax.h
index 7328d50..322ff4f 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -423,7 +423,6 @@ struct wimax_dev {
 	int (*op_reset)(struct wimax_dev *wimax_dev);
 
 	struct rfkill *rfkill;
-	struct input_dev *rfkill_input;
 	unsigned rf_hw;
 	unsigned rf_sw;
 	char name[32];
-- 
1.7.0.4
