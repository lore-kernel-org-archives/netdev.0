From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/7] Marvell SysKonnect related driver fixes
Date: Wed, 12 Jul 2006 15:23:41 -0700
Message-ID: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20105 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751470AbWGLWb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:59 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor fixes for sky2 and related drivers.  Includes the collision
threshold mask (and related drivers). 

Known outstanding problems:
  * sky2 hangs which are unreproducible on the machines in 
    my environment :-(
  * sky2 probably has problems on dual-port card on pci-express,
    fixed on pci-x
  * wake on LAN still not supported
--

