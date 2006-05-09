From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Associate on 'ifconfig up'
Date: Tue, 09 May 2006 19:53:19 +0100
Message-ID: <1147200799.2794.60.camel@pmac.infradead.org>
References: <1146847107.2766.13.camel@pmac.infradead.org>
	 <1146939849.2503.108.camel@shinybook.infradead.org>
	 <200605071506.06552.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:1721 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1750821AbWEISxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 14:53:43 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605071506.06552.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-05-07 at 15:06 +0200, Michael Buesch wrote:
> On Saturday 06 May 2006 20:24, David Woodhouse wrote:
> > On Fri, 2006-05-05 at 17:38 +0100, David Woodhouse wrote:
> > > I still need this hack to work around the fact that softmac doesn't
> > > attempt to associate when we bring the device up...
> > 
> > It'd be quite good to get this fixed in 2.6.17 too. Otherwise, the
> > device doesn't manage to associate if you use the fairly common sequence
> > of iwconfig then dhclient.
> > 
> > It's a bit of an evil hack and it should really be fixed in softmac --
> > but it's only moving an _existing_ hack from one place in the driver to
> > another.
> > 
> > Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> John, please try to push this before 2.6.17.
> Thanks.

This didn't make it into the tree that Linus just pulled?

-- 
dwmw2

