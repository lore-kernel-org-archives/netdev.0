From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v4 0/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 5 Jun 2015 18:00:23 -0500
Message-ID: <1433545226-18324-1-git-send-email-jaeden.amero@ni.com>
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

In v4, we modify the commit message of "net/phy: micrel: Center FLP timing
at 16ms" to replace the awkward quotation of the data sheet's programming
procedure with an explanation of why we program the FLP burst registers and
restart auto-negotiation where we do (config_init).

Jaeden Amero (3):
  net/phy: micrel: Be more const correct
  net/phy: micrel: Comment MMD address of extended registers
  net/phy: micrel: Center FLP timing at 16ms

 drivers/net/phy/micrel.c | 53 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 15 deletions(-)

-- 
2.1.4
