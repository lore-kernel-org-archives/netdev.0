From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 00/11] r8152: minor adjustment
Date: Fri, 9 Jun 2017 17:11:37 +0800
Message-ID: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust some code to make it reasonable or satisfy the suggestion from
the engineers.

Hayes Wang (11):
  r8152: add r8153_phy_status function
  r8152: adjust lpm settings for RTL8153
  r8152: adjust the settings about MAC clock speed down for RTL8153
  r8152: move the setting of rx aggregation
  r8152: adjust rtl8153_runtime_enable function
  r8152: adjust U2P3 for RTL8153
  r8152: move the default coalesce setting for RTL8153
  r8152: move the initialization to reset_resume function
  r8152: check if disabling ALDPS is finished
  r8152: avoid rx queue more than 1000 packets
  r8152: replace napi_complete with napi_complete_done

 drivers/net/usb/r8152.c | 181 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 130 insertions(+), 51 deletions(-)

-- 
2.7.4
