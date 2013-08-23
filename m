From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND V3 net-next 0/3] huawei_cdc_ncm driver introduction
Date: Fri, 23 Aug 2013 09:56:27 +0200
Message-ID: <1377244590-8558-1-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are all related to the new huawei_cdc_ncm driver, supporting 
devices that use the NCM protocol as a transport layer for other protocols. 
this is the case of the Huawei E3131 3G modem.

In this version - I actually added the driver file! :) I don't know how I ended 
up forgetting about it, I should have learned git usage better after all this 
time! Sorry for the time I wasted you.

Enrico Mioso (3):
  net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
  net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
  net: cdc_ncm: remove non-standard NCM device IDs

 drivers/net/usb/Kconfig          |   11 ++
 drivers/net/usb/Makefile         |    1 +
 drivers/net/usb/cdc_ncm.c        |   17 +--
 drivers/net/usb/huawei_cdc_ncm.c |  210 ++++++++++++++++++++++++++++++++++++++
 include/linux/usb/cdc_ncm.h      |    3 +
 5 files changed, 229 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/usb/huawei_cdc_ncm.c

-- 
1.7.10.4
