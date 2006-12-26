From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 6/7] PHY probe not working properly for ibm_emac (PPC4xx)
Date: Tue, 26 Dec 2006 16:41:25 -0500
Message-ID: <45919705.9090002@garzik.org>
References: <200612192108.kBJL8oDM010504@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hynek@swac.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41562 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809AbWLZVl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:41:28 -0500
To: akpm@osdl.org
In-Reply-To: <200612192108.kBJL8oDM010504@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Hynek Petrak <hynek@swac.cz>
> 
> I have a system with AMCC PowerPC 405EP and PHY Intel LXT971A.  Linux
> 2.6.18.3 is not able to detect the PHY ID correctly.  The PHY ID
> detected is 0, but should be 0x1d.
> 
> This is because phy_read() (__emac_mdio_read() resp.) from
> drivers/net/ibm_emac/ibm_emac_core.c might return -ETIMEDOUT or
> -EREMOTEIO on error.  This is ignored inside the
> 
> int mii_phy_probe(struct mii_phy *phy, int address)
> from drivers/net/ibm_emac/ibm_emac_phy.c
> 
> as the return value is assigned to an u32 variable.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


