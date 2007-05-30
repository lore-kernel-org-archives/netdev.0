From: Jose Alberto Reguero <jareguero@telefonica.net>
Subject: Problem with atl1 and msi in kernel 2.6.22-rc3
Date: Wed, 30 May 2007 02:00:25 +0200
Message-ID: <200705300200.25412.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.telefonica.net ([213.4.149.66]:65150 "EHLO
	ctsmtpout3.frontal.correo" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751049AbXE3AAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 20:00:33 -0400
Received: from jar.dominio (80.25.230.35) by ctsmtpout3.frontal.correo (7.2.056.6) (authenticated as jareguero$telefonica.net)
        id 465C8EB600005B99 for netdev@vger.kernel.org; Wed, 30 May 2007 02:00:32 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have problems with a M2V motherboard and atl1 driver with msi and kernel 
2.6.22-rc3. With kernel 2.6.21 I had no problems.
I must add in drivers/pci/quirks.c (line 1723):

 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_ATI, PCI_DEVICE_ID_ATI_RS480, 
quirk_disable_msi);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_VIA, 0xe238, quirk_disable_msi);

to disable msi in the atl1.

Thanks.
Jose Alberto
