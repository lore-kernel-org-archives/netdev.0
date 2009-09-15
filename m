From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] igb: reset sgmii phy at start of init
Date: Mon, 14 Sep 2009 17:08:57 -0700 (PDT)
Message-ID: <20090914.170857.58124243.davem@davemloft.net>
References: <20090914182253.4859.11176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933573AbZIOAIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:08:40 -0400
In-Reply-To: <20090914182253.4859.11176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 14 Sep 2009 11:22:54 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Our SGMII phy code was incomplete in that it was not actually placing the
> phy in SGMII mode and as a result the PHY was not able to establish a link
> when connected to a non serdes link partner.  This patch updates the code
> to combine the SGMII/serdes PCS init and to add the necessary reset.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>

Applied.
