From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: Tue, 12 Sep 2006 10:43:21 -0400
Message-ID: <4506C789.4050404@pobox.com>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>	<1157962200.10526.10.camel@localhost.localdomain>	<1158051351.14448.97.camel@localhost.localdomain> <ada3bax2lzw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zang Roy-r61911 <tie-fei.zang@freescale.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965153AbWILOne@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <ada3bax2lzw.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > +struct tsi108_prv_data {
>  > +	volatile u32 regs;	/* Base of normal regs */
>  > +	volatile u32 phyregs;	/* Base of register bank used for PHY access */
> 
> Why volatile?  This looks really wrong here.

Indeed.


>  > +	data->regs = (u32)ioremap(einfo->regs, 0x400);	/*FIX ME */
>  > +	data->phyregs = (u32)ioremap(einfo->phyregs, 0x400); 	/*FIX ME */
> 
> What needs to be fixed here?  And why are you casting the result of
> ioremap to u32?  Shouldn't you keep the normal return value?

Oh, that's very, very wrong.

	Jeff
