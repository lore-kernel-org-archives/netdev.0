From: David Miller <davem@davemloft.net>
Subject: Re: pci: Added quirk to disable msi for MCP55 NIC on Asus
 P5N32-SLI Premium
Date: Wed, 19 Nov 2008 14:13:18 -0800 (PST)
Message-ID: <20081119.141318.89771247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: apetlund@simula.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751329AbYKSWNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:13:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't start calling dmi_*() routines in drivers/pci/quirks.c without
including linux/dmi.h there, otherwise it doesn't build on some platforms:

drivers/pci/quirks.c: In function 'nvenet_msi_disable':
drivers/pci/quirks.c:1837: error: implicit declaration of function 'dmi_name_in_vendors'
make[1]: *** [drivers/pci/quirks.o] Error 1
