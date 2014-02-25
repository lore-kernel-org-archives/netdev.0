From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [RFC 3/3] bnx2x: Use pci_set_power_state() for setting PM states
Date: Tue, 25 Feb 2014 11:21:13 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF6EE08@SJEXCHMB10.corp.ad.broadcom.com>
References: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
 <1393281245-3951-3-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <ariele@broadcom.com>
To: Jon Mason <jdmason@kudzu.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:60062 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaBYLVP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 06:21:15 -0500
In-Reply-To: <1393281245-3951-3-git-send-email-jdmason@kudzu.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Use the existing infrastructure of pci_set_power_state() instead of
> setting the relevant bits via PCI config read/write in the driver.
> Also, use the d3_delay field to specify how long to msleep after putting
> the device in the appropriate power management state.  Finally, use
> pci_pme_active() to set the PCI_PM_CTRL_PME_ENABLE bit in PCI PM control
> register.  pci_set_power_state() and pci_pme_active() perform the same
> operations as the driver did before, so there should be no functional
> change.  That being said, this has not been tested.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> Cc: Ariel Elior <ariele@broadcom.com>

Acked-by: Yuval Mintz <yuvalmin@broadcom.com>
