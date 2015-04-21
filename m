From: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Subject: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB RMII interface.
Date: Tue, 21 Apr 2015 13:26:28 +0000
Message-ID: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: kaisrja1@fel.cvut.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kaisrlik <ja.kaisrlik@gmail.com>

This RFC patch enables connecting a DSA-based switch to the USB RMII interface.

I use switch Marvell 88E6065 as the DSA-based switch
connected to USB RMII interface provides by Asix AX88772b.

I temporarily modified the mv88e6060 driver to work with 88E6065.

Jan Kaisrlik (3):
  net/dsa: Refactor dsa_probe()
  net/dsa: Allow probing dsa from usbnet
  driver/net/usb: Add support for DSA to ax88772b

 drivers/net/usb/asix.h         |   7 ++
 drivers/net/usb/asix_devices.c | 258 ++++++++++++++++++++++++++++++++++++++++-
 include/net/dsa.h              |   3 +
 net/dsa/dsa.c                  | 197 ++++++++++++++++++++++++++-----
 4 files changed, 429 insertions(+), 36 deletions(-)

-- 
2.1.3
