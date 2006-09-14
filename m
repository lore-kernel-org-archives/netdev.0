From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: 14 Sep 2006 10:51:01 +0800
Message-ID: <1158202261.22615.0.camel@localhost.localdomain>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
	 <1158051351.14448.97.camel@localhost.localdomain>
	 <ada3bax2lzw.fsf@cisco.com>  <4506C789.4050404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:57060 "EHLO
	de01egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1750966AbWINCvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 22:51:15 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4506C789.4050404@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-12 at 22:43, Jeff Garzik wrote:
> Roland Dreier wrote:
> >  > +struct tsi108_prv_data {
> >  > +  volatile u32 regs;      /* Base of normal regs */
> >  > +  volatile u32 phyregs;   /* Base of register bank used for PHY
> access */
> > 
> > Why volatile?  This looks really wrong here.
> 
> Indeed.
I will remove it.
> 
> 
> >  > +  data->regs = (u32)ioremap(einfo->regs, 0x400);  /*FIX ME */
> >  > +  data->phyregs = (u32)ioremap(einfo->phyregs, 0x400);    /*FIX
> ME */
> > 
> > What needs to be fixed here?  And why are you casting the result of
> > ioremap to u32?  Shouldn't you keep the normal return value?
> 
> Oh, that's very, very wrong.
I will find method to avoid this :-).
Roy

