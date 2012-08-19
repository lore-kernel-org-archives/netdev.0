From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/fsl: introduce Freescale 10G MDIO driver
Date: Mon, 20 Aug 2012 00:48:04 +0200
Message-ID: <20120819224804.GA28300@electric-eye.fr.zoreil.com>
References: <1345233792-14985-1-git-send-email-timur@freescale.com> <20120819205724.GA27555@electric-eye.fr.zoreil.com> <50315A18.2040105@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39038 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab2HSXDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 19:03:39 -0400
Content-Disposition: inline
In-Reply-To: <50315A18.2040105@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tabi Timur-B04825 <B04825@freescale.com> :
[...]
> I don't see any real savings here.

xgmac_mdio_free_bus_wait could return -ETIMEDOUT and include the
debug message.

-- 
Ueimor
