From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] TI DaVinci EMAC: Fix incorrect reference to
 EMAC_CTRL registers.
Date: Fri, 30 Jul 2010 23:56:26 -0700 (PDT)
Message-ID: <20100730.235626.179932800.davem@davemloft.net>
References: <1280406840-27393-1-git-send-email-srk@ti.com>
	<1280406840-27393-2-git-send-email-srk@ti.com>
	<1280406840-27393-3-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, nsekhar@ti.com,
	anantgole@ti.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752510Ab0GaG4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:56:09 -0400
In-Reply-To: <1280406840-27393-3-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Thu, 29 Jul 2010 18:04:00 +0530

> The EMAC modules control registers vary as per the version of the
> EMAC module. EMAC_CTRL_EWCTL,EMAC_CTRL_EWINTTCNT are available
> only on EMAC_VERSION_1. The emac_dump_regs() function accesses
> these indiscriminately. This patch fixes the issue.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>

Also applied, thank you.
