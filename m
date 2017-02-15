From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 0/8] net: stmmac: misc patchs
Date: Wed, 15 Feb 2017 08:39:10 +0100
Message-ID: <20170215073910.GA12040@Red>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
 <241535e2-36fb-d3f7-5da8-289c1c1bbcc6@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34741 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdBOHjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 02:39:15 -0500
Content-Disposition: inline
In-Reply-To: <241535e2-36fb-d3f7-5da8-289c1c1bbcc6@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 07:34:41AM +0100, Giuseppe CAVALLARO wrote:
> Hello Corentin
> 
> On 2/14/2017 8:54 PM, Corentin Labbe wrote:
> > Hello
> >
> > This is a follow up of my previous stmmac serie which address some comment
> > done in v2.
> 
> I wonder if you can resend all the patches as V3
> please add the Acked-by and Reviewed-by. This will help
> on final review and integration.
> 
> Thx for your support and effort
> 
> Peppe
> 

Hello

Since all patch in v2 already hit linux-next, I just want to be sure, I can add "Acked-by and Reviewed-by" to thoses 8 new patchs ?

Regards

> >
> > Corentin Labbe (8):
> >   net: stmmac: remove useless parenthesis
> >   net: stmmac: likely is useless in occasional function
> >   net: stmmac: use SPEED_UNKNOWN/DUPLEX_UNKNOWN
> >   net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
> >   net: stmmac: run stmmac_hw_fix_mac_speed when speed is valid
> >   net: stmmac: split the stmmac_adjust_link 10/100 case
> >   net: stmmac: reduce indentation by adding a continue
> >   net: stmmac: invert the logic for dumping regs
> >
> >  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 18 ++---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 40 ++++++-----
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 82 +++++++++++-----------
> >  3 files changed, 71 insertions(+), 69 deletions(-)
> >
> 
