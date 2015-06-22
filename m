From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RFC 0/2] huawei_cdc_ncm: new NCM TX stack for Huawei-style NCM
Date: Tue, 23 Jun 2015 00:32:13 +0200
Message-ID: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Oliver Neukum <oneukum@suse.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33145 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbbFVWdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 18:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an ALFA version of my new NCM TX engine, built with huawei-style NCM and flexibility in mind.
The main goal is to allow foreasily re-ordering NCM frame content.
Basic communication works - but an usbnet EVENT_RX_MEMORY will stop the process after some packets.
Any idea or comment about any aspect of this code is really apreciated - 
including suggestions for style and over-long lines problematic to break down, 
at least for me.


Lots of lines longer than 80 chars seemed not easily breakable to me: any 
suggestion is welcome.

Enrico Mioso (2):
  cdc_ncm: export cdc_ncm_align_tail
  huawei_cdc_ncm: introduce new TX ncm stack

 drivers/net/usb/cdc_ncm.c        |   3 +-
 drivers/net/usb/huawei_cdc_ncm.c | 187 ++++++++++++++++++++++++++++++++++++++-
 include/linux/usb/cdc_ncm.h      |   1 +
 3 files changed, 188 insertions(+), 3 deletions(-)

-- 
2.4.4
