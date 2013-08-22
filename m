From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next V2 0/3] huawei_cdc_ncm introduction
Date: Thu, 22 Aug 2013 04:30:38 +0200
Message-ID: <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These patches are all related to the new huawei_cdc_ncm driver, supporting 
devices that use the NCM protocol as a transport layer for other protocols. 
this is the case of the Huawei E3131 3G modem.
Thanks should go to bjorn and others who helped me with patience.

Enrico Mioso (3):
  net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
  net: huawei_cdc_ncm: Introduce the
  net: cdc_ncm: remove non-standard NCM device IDs

 drivers/net/usb/Kconfig     |   11 +++++++++++
 drivers/net/usb/Makefile    |    1 +
 drivers/net/usb/cdc_ncm.c   |   17 ++++-------------
 include/linux/usb/cdc_ncm.h |    3 +++
 4 files changed, 19 insertions(+), 13 deletions(-)

-- 
This version includes mainly cosmetic fixes related to patches.
1.7.10.4
