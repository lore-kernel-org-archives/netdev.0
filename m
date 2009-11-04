From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI DaVinci EMAC: Add suspend/resume capability
Date: Wed, 04 Nov 2009 05:22:08 -0800 (PST)
Message-ID: <20091104.052208.26529647.davem@davemloft.net>
References: <1257338991-19792-1-git-send-email-ranjithl@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, chaithrika@ti.com
To: ranjithl@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbZKDNVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:21:43 -0500
In-Reply-To: <1257338991-19792-1-git-send-email-ranjithl@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ranjith Lohithakshan <ranjithl@ti.com>
Date: Wed,  4 Nov 2009 18:19:51 +0530

> Add suspend/resume capability to TI DaVinci EMAC driver.
> 
> Signed-off-by: Ranjith Lohithakshan <ranjithl@ti.com>
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> ---
> Applies to net-next-2.6

I don't think the CONFIG_PM CPP ifdefs are necessary.

Drivers generally don't do this, and they build just fine
on sparc64 which never sets CONFIG_PM ;-)
