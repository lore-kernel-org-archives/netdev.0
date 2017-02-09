From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 0/2] net: ethernet: ti: cpsw: fix susp/resume
Date: Thu,  9 Feb 2017 02:07:34 +0200
Message-ID: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        AStarikovskiy@topcon.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches fix suspend/resume chain.

Ivan Khoronzhuk (2):
  net: ethernet: ti: cpsw: fix cpsw assignment in resume
  net: ethernet: ti: cpsw: fix resume because of usage count

 drivers/net/ethernet/ti/cpsw.c | 44 +++++++++++++-----------------------------
 1 file changed, 13 insertions(+), 31 deletions(-)

-- 
2.7.4
