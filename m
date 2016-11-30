From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net 04/16] net: ethernet: aurora: nb8800: fix fixed-link
 phydev leaks
Date: Wed, 30 Nov 2016 10:51:17 +0100
Message-ID: <20161130095117.GH29872@localhost>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
 <1480357509-28074-5-git-send-email-johan@kernel.org>
 <583E9DAD.8090205@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sebastian Frias <sf84@laposte.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>,
        Brian Norris <computersforpeace@gmail.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35898 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933689AbcK3JvY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:51:24 -0500
Content-Disposition: inline
In-Reply-To: <583E9DAD.8090205@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 10:36:45AM +0100, Mason wrote:
> On 28/11/2016 19:24, Johan Hovold wrote:
> 
> > Make sure to deregister and free any fixed-link PHY registered using
> > of_phy_register_fixed_link() on probe errors and on driver unbind.
> > 
> > Fixes: c7dfe3abf40e ("net: ethernet: nb8800: support fixed-link DT node")
> > Signed-off-by: Johan Hovold <johan@kernel.org>
> > ---
> >  drivers/net/ethernet/aurora/nb8800.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Did you use scripts/get_maintainer.pl ?
> 
> Neither the author of the driver (Mans) nor the author of
> the code in question (Sebastian) were CCed on this patch.

I did, but I only included parties listed as maintainers, not commit
signers, to keep the already large CC list down somewhat.

Johan
