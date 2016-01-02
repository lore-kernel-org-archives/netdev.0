From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net-rsi: Fine-tuning for two function implementations
Date: Sat, 2 Jan 2016 15:40:41 +0100
Message-ID: <5687E169.4070704@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 15:36:25 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Delete unnecessary variable initialisations in rsi_send_mgmt_pkt()
  Delete unnecessary variable initialisations in rsi_send_data_pkt()
  Replace variable initialisations by assignments in rsi_send_data_pkt()

 drivers/net/wireless/rsi/rsi_91x_pkt.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

-- 
2.6.3
