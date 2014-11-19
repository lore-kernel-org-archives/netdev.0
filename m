From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/2] r8152: adjust rx functions
Date: Wed, 19 Nov 2014 13:20:40 +0800
Message-ID: <1394712342-15778-95-Taiwan-albertk@realtek.com>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-88-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
For patch #1, set actual_length to 0 before adding the rx to the
list, when a error occurs.

For patch #2, change the flow. Stop submitting the rx if a error
occurs, and add the remaining rx to the list for submitting later.

v1:
Adjust some flows and codes which are relative to r8152_submit_rx()
and rtl_start_rx().

Hayes Wang (2):
  r8152: adjust r8152_submit_rx
  r8152: adjust rtl_start_rx

 drivers/net/usb/r8152.c | 60 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 40 insertions(+), 20 deletions(-)

-- 
1.9.3
