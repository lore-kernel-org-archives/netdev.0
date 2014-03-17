From: Andres Bertens <abertensu@yahoo.com>
Subject: Fwd: Fwd: Linux 3.4.83 update: wireless card (iwlwifi) stop working
Date: Mon, 17 Mar 2014 15:33:11 -0300
Message-ID: <53273FE7.4050301@yahoo.com>
References: <53273A0B.7070108@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm6-vm4.bullet.mail.ne1.yahoo.com ([98.138.91.166]:39502 "EHLO
	nm6-vm4.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756833AbaCQSif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 14:38:35 -0400
In-Reply-To: <53273A0B.7070108@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As I was told, perhaps you are a better destination for this finding.

Regards,
Andres Bertens


-------- Original Message --------
Subject: Linux 3.4.83 update: wireless card (iwlwifi) stop working
Date: Wed, 12 Mar 2014 14:46:14 -0300
From: Andres Bertens <abertensu@yahoo.com>
To: linux-kernel@vger.kernel.org

Hi,

I updated today to 3.4.83 kernel and my wireless card stop working (log
says: iwlwifi 0000:03:00.0: Unable to initialize device).

My laptop is a Lenovo Thinkpad X230, with an Intel 6205 AGN card.

Reverting patch
     Johannes Berg <johannes.berg@intel.com>
        iwlwifi: always copy first 16 bytes of commands
makes it work again.

Regards,
Andres Bertens

PS
If of any interest, here are the related logs:

Linux mintaka 3.4.83-smp #1 SMP Wed Mar 12 13:10:44 CLST 2014 x86_64
x86_64 x86_64 GNU/Linux

Linux-3.4.83, device not working:
--------------------------------
iwlwifi 0000:03:00.0: pci_resource_len = 0x00002000
iwlwifi 0000:03:00.0: pci_resource_base = ffffc90006618000
iwlwifi 0000:03:00.0: HW Revision ID = 0x34
iwlwifi 0000:03:00.0: irq 42 for MSI/MSI-X
iwlwifi 0000:03:00.0: loaded firmware version 18.168.6.1
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEBUG disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEBUGFS disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEVICE_TRACING disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEVICE_TESTMODE disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_P2P disabled
iwlwifi 0000:03:00.0: Detected Intel(R) Centrino(R) Advanced-N 6205 AGN,
REV=0xB0
iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
iwlwifi 0000:03:00.0: device EEPROM VER=0x715, CALIB=0x6
iwlwifi 0000:03:00.0: Device SKU: 0x1F0
iwlwifi 0000:03:00.0: Valid Tx ant: 0x3, Valid Rx ant: 0x3
iwlwifi 0000:03:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
iwlwifi 0000:03:00.0: Radio type=0x1-0x2-0x0
iwlwifi 0000:03:00.0: Error sending CALIBRATION_CFG_CMD: time out after
2000ms.
iwlwifi 0000:03:00.0: Current CMD queue read_ptr 2 write_ptr 3
iwlwifi 0000:03:00.0: Failing on timeout while stopping DMA channel 7
[0x077f0001]
iwlwifi 0000:03:00.0: Failed to run INIT ucode: -110
iwlwifi 0000:03:00.0: Unable to initialize device.


Linux-3.4.83, patch remove, device working:
-------------------------------------------
iwlwifi 0000:03:00.0: pci_resource_len = 0x00002000
iwlwifi 0000:03:00.0: pci_resource_base = ffffc9000672c000
iwlwifi 0000:03:00.0: HW Revision ID = 0x34
iwlwifi 0000:03:00.0: irq 42 for MSI/MSI-X
iwlwifi 0000:03:00.0: loaded firmware version 18.168.6.1
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEBUG disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEBUGFS disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEVICE_TRACING disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_DEVICE_TESTMODE disabled
iwlwifi 0000:03:00.0: CONFIG_IWLWIFI_P2P disabled
iwlwifi 0000:03:00.0: Detected Intel(R) Centrino(R) Advanced-N 6205 AGN,
REV=0xB0
iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
iwlwifi 0000:03:00.0: device EEPROM VER=0x715, CALIB=0x6
iwlwifi 0000:03:00.0: Device SKU: 0x1F0
iwlwifi 0000:03:00.0: Valid Tx ant: 0x3, Valid Rx ant: 0x3
iwlwifi 0000:03:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
iwlwifi 0000:03:00.0: Radio type=0x1-0x2-0x0
iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
iwlwifi 0000:03:00.0: Radio type=0x1-0x2-0x0
