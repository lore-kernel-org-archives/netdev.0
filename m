From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v3 0/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 5 Jun 2015 17:40:43 -0500
Message-ID: <1433544046-17595-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In v2, we add an additional cleanup commit to make an array of strings
static const and to improve const correctness generally. We also no longer
unnecessarily initialize the result variable in
ksz9031_center_flp_timing().

In v3, we remove the unnecessary result variable from ksz9031_config_init()
introduced by a previous version of "net/phy: micrel: Center FLP timing at
16ms".

Jaeden Amero (3):
  net/phy: micrel: Be more const correct
  net/phy: micrel: Comment MMD address of extended registers
  net/phy: micrel: Center FLP timing at 16ms

 drivers/net/phy/micrel.c | 53 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 15 deletions(-)

-- 
2.1.4
