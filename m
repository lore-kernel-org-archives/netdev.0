From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: Thu, 25 Oct 2007 13:51:19 +0200
Message-ID: <20071025115119.GA7543@xi.wantstofly.org>
References: <20071016192806.GD19618@xi.wantstofly.org> <47205DE4.7040001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:34595 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757060AbXJYLvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 07:51:21 -0400
Content-Disposition: inline
In-Reply-To: <47205DE4.7040001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 25, 2007 at 05:12:04AM -0400, Jeff Garzik wrote:

> >+struct rx_desc {
> >+	u32 cmd_sts;
> >+	u16 size;
> >+	u16 count;
> >+	u32 buf;
> >+	u32 next;
> >+};
> >+
> >+struct tx_desc {
> >+	u32 cmd_sts;
> >+	u16 l4i_chk;
> >+	u16 count;
> >+	u32 buf;
> >+	u32 next;
> >+};
> 
> should use sparse type (__le32, etc.) and make sure this driver passes 
> sparse checks
> 
> ditto for checkpatch (except for the excessively anal stuff)

Sorry if it wasn't clear from the thread -- the mainline mv643xx_eth
driver turns out to support the same silicon block (but as part of a
different chip), so we've dropped orion_eth and submitted patches to
make mv643xx_eth work on both the Discovery (what it was originally
written for) and the Orion, and these patches are in -rc1 already.
