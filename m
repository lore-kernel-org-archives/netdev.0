From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] fec: use interrupt for MDIO completion indication
Date: Thu, 15 Jul 2010 07:09:56 +0300
Message-ID: <20100715040956.GA7690@jasper.tkos.co.il>
References: <006416d38a8e51ba8dd8631613a991528dc7976a.1278918594.git.baruch@tkos.co.il>
 <4C3E812C.10303@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sascha Hauer <kernel@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Wolfram Sang <w.sang@pengutronix.de>
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:34295 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707Ab0GOEKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 00:10:24 -0400
Content-Disposition: inline
In-Reply-To: <4C3E812C.10303@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bryan,

On Thu, Jul 15, 2010 at 11:31:56AM +0800, Bryan Wu wrote:
> Thanks for this patch, we tested on our i.MX51 board with Ubuntu. It works 
> fine.
> 
> Wolfram, you can pick up this, too. -;)

Dave has already applied this patch to his net-next tree.

baruch

> On 07/12/2010 03:12 PM, Baruch Siach wrote:
> > With the move to phylib (commit e6b043d) I was seeing sporadic "MDIO write
> > timeout" messages. Measure of the actual time spent showed latency times of
> > more than 1600us.
> > 
> > This patch uses the MII event indication of the FEC hardware to detect
> > completion of MDIO transactions.
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> >  drivers/net/fec.c |   55 ++++++++++++++++++++++++----------------------------
> >  1 files changed, 25 insertions(+), 30 deletions(-)
> > 

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
