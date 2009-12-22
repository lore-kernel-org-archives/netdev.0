From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 2/4] mx25: don't force input on FEC pins
Date: Tue, 22 Dec 2009 09:12:21 +0200
Message-ID: <20091222071221.GA5286@jasper.tkos.co.il>
References: <cover.1260785451.git.baruch@tkos.co.il>
 <a7c4a6919d5687cefa6ad12fb8bf2b08733823da.1260785451.git.baruch@tkos.co.il>
 <20091221110409.GD15126@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <kernel@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:40313 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbZLVHNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2009 02:13:35 -0500
Content-Disposition: inline
In-Reply-To: <20091221110409.GD15126@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Mon, Dec 21, 2009 at 12:04:09PM +0100, Sascha Hauer wrote:
> On Mon, Dec 14, 2009 at 12:19:40PM +0200, Baruch Siach wrote:
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> >  arch/arm/plat-mxc/include/mach/iomux-mx25.h |   20 ++++++++++----------
> >  1 files changed, 10 insertions(+), 10 deletions(-)
> 
> Can you explain why this is needed in the commit message please?

I tested FEC support without this patch and indeed this patch is not 
necessary.

I just whether there is any benefit in setting the SION bit to a non default 
mode.

Anyway, you can just discard this patch.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
