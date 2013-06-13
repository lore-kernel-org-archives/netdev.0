From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Wed, 12 Jun 2013 20:46:02 -0700
Message-ID: <1371095162.31941.1.camel@joe-AO722>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130612230257.GB21234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	mcgrof@do-not-panic.com, kvalo@adurom.com, adrian.chadd@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50862 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932508Ab3FMDqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 23:46:04 -0400
In-Reply-To: <20130612230257.GB21234@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 01:02 +0200, Francois Romieu wrote:
> Johannes Berg <johannes@sipsolutions.net> :
> > diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
[]
> > +static int __alx_read_phy_dbg(struct alx_hw *hw, u16 reg, u16 *pdata)
> > +{
> > +	int err;
> > +
> > +	err = __alx_write_phy_reg(hw, ALX_MII_DBG_ADDR, reg);
> > +	if (err)
> > +		return err;
> > +
> > +	return __alx_read_phy_reg(hw, ALX_MII_DBG_DATA, pdata);
> 
> 	return err ? err : __alx_read_phy_reg(hw, ALX_MII_DBG_DATA, pdata);

I think that's far poorer style.
