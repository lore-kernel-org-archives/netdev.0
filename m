From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 0/7] pci: Add VPD parsing support
Date: Fri, 26 Feb 2010 12:40:31 -0800
Message-ID: <1267216838-19459-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com
To: jbarnes@virtuousgeek.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds code to help parse a device's VPD.  The bnx2 and tg3
network drivers are modified as an example on how to use the API.  I
believe the bnx2x driver will also use this API in the future.

Changes from v1:
* Renamed pci_vpd_find_tag() and pci_vpd_find_info_keyword() parameter names.
* Added docbook notations for functions and inline functions.
* Moved pci-vpd.h contents to pci.h
