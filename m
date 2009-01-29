From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/20] sfc: Fixes and new PHY support for 2.6.29
Date: Thu, 29 Jan 2009 19:12:38 +0000
Message-ID: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:37529 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751678AbZA2TMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:12:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please take the following changes for 2.6.29.

The changes are made up of:
- Bug fixes based on internal QA for version 2.3
- Addition of one new PHY and board
- A small feature addition for the SFT9001 (which is itself new for .29)

Ben.

Ben Hutchings (14):
  sfc: SFT9001: Include non-breaking cable diagnostics in online
    self-tests
  sfc: Fix test for MDIO read failure
  sfc: SFT9001/SFN4111T: Check PHY boot status during board
    initialisation
  sfc: SFN4111T: Fix GPIO sharing between I2C and FLASH_CFG_1
  sfc: Update board info for hardware monitor on SFN4111T-R5 and later
  sfc: SFT9001: Always enable XNP exchange on SFT9001 rev B
  sfc: SFX7101/SFT9001: Fix AN advertisements
  sfc: Remove "XFP" from log messages that are not specific to XFP
  sfc: Fix reporting of PHY id
  sfc: Add support for QT2025C PHY
  sfc: Delete unused efx_blinker::led_num field
  sfc: Clean up LED control
  sfc: Add support for SFN4112F SFP+ reference design
  sfc: Replace stats_enabled flag with a disable count

Steve Hodgson (6):
  sfc: SFT9001: Enable robust link training
  sfc: SFX7101: Remove workaround for bad link training
  sfc: SFT9001: Fix speed reporting in 1G PHY loopback
  sfc: Fix post-reset MAC selection
  sfc: Reinitialise the PHY completely in case of a PHY or NIC reset
  sfc: Test for PHYXS faults whenever we cannot test link state bits
	
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

