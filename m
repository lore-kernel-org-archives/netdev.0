From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 20:04:09 +0200
Message-ID: <201209212004.10148.marex@denx.de>
References: <1348195976-31703-1-git-send-email-marex@denx.de> <20120921.134215.1719885507288305623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:49409 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab2IUSEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:04:14 -0400
In-Reply-To: <20120921.134215.1719885507288305623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

> From: Marek Vasut <marex@denx.de>
> Date: Fri, 21 Sep 2012 04:52:54 +0200
> 
> > +	phy_write(phydev, MII_KSZPHY_OMSO,
> > +		KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE);
> 
> This is not indented properly.  The goal is not to exclusively use
> TAB characters to indent code until it sort-of looks fine.

The goal was to avoid checkpatch trouble.

> Rather, the goal is to properly line up function arguments with
> the first column after the openning parenthesis on the previous
> line.  Using TAB and SPACE characters, as needed.
> 
> > +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> > +				| SUPPORTED_Asym_Pause),
> 
> This is similarly not styled properly.

This is copy-pasted from other entry. I'd hate to reformat the whole file.

> Besies being indented imporperly on the second line, the final "|"
> character should be at the end of the first line, rather than
> start the second line.

DTTO here.

> Resubmit this entire patch series, not just this one patch, once
> you've made these corrections.
> 
> Thanks.

Best regards,
Marek Vasut
