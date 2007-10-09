From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
 ISDN
Date: Mon, 08 Oct 2007 20:37:33 -0700 (PDT)
Message-ID: <20071008.203733.132907566.davem@davemloft.net>
References: <20071007131723.GA22873@rhlx01.hs-esslingen.de>
	<20071007172037.GA29384@rhlx01.hs-esslingen.de>
	<20071008155836.GA19932@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@lisas.de, jeff@garzik.org, isdn4linux@listserv.isdn4linux.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751704AbXJIDhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 23:37:34 -0400
In-Reply-To: <20071008155836.GA19932@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karsten Keil <kkeil@suse.de>
Date: Mon, 8 Oct 2007 17:58:36 +0200

> On Sun, Oct 07, 2007 at 07:20:37PM +0200, Andreas Mohr wrote:
> > Hi,
> > 
> > On Sun, Oct 07, 2007 at 03:17:24PM +0200, Andreas Mohr wrote:
> > > I thus decided to now try plain 2.6.23-rc8 whether it's "corrupted", too.
> > 
> > OK, after 3 hours of compilation the ONLY datapoint I can give right now is:
> > 1 (one) boot on 2.6.23-rc8-mm2 had the BUG in /var/log/messages,
> > 1 (one) boot on 2.6.23-rc8 did NOT have it.
> > 
> > The two .config:s (I did a make oldconfig when going back to
> > non-mm2) don't seem to have any relevant differences.
> > 
> > I could offer to do more testing on this machine,
> > but this carries a slight risk for me since I (personally) won't have physical
> > access to it for a couple days and some people will kill me if the main
> > internet gateway happened to go down unfixably. ;)
> >
> 
> You could try following patch with 2.6.23-rc8-mm2, it change I4L to use
> alloc_netdev().
> 
> Signed-off-by: Karsten Keil <kkeil@suse.de>

I've added this patch to net-2.6.24, thanks Karsten!
