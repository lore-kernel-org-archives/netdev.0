From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next 0/3] huawei_cdc_ncm introduction
Date: Tue, 20 Aug 2013 16:50:52 +0200
Message-ID: <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:46193 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3HTOvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 10:51:35 -0400
Received: by mail-wi0-f169.google.com with SMTP id f14so580704wiw.2
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 07:51:34 -0700 (PDT)
In-Reply-To: <mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
1.7.10.4
