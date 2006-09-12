From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: Tue, 12 Sep 2006 07:33:07 -0700
Message-ID: <ada3bax2lzw.fsf@cisco.com>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	<1157962200.10526.10.camel@localhost.localdomain>
	<1158051351.14448.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jgarzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:34171 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S965250AbWILOdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 10:33:09 -0400
To: Zang Roy-r61911 <tie-fei.zang@freescale.com>
In-Reply-To: <1158051351.14448.97.camel@localhost.localdomain> (Zang Roy-r's message of "12 Sep 2006 16:55:52 +0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +struct tsi108_prv_data {
 > +	volatile u32 regs;	/* Base of normal regs */
 > +	volatile u32 phyregs;	/* Base of register bank used for PHY access */

Why volatile?  This looks really wrong here.

 > +	data->regs = (u32)ioremap(einfo->regs, 0x400);	/*FIX ME */
 > +	data->phyregs = (u32)ioremap(einfo->phyregs, 0x400); 	/*FIX ME */

What needs to be fixed here?  And why are you casting the result of
ioremap to u32?  Shouldn't you keep the normal return value?

 - R.
