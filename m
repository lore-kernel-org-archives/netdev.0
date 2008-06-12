From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non pausing driver core
Date: Thu, 12 Jun 2008 16:37:30 -0500 (CDT)
Message-ID: <26598825.1213306650905.JavaMail.oracle@acsmt303.oracle.com>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
	<20080610001329.GA16197@devserv.devel.redhat.com>
	<20080609171945.d2360114.akpm@linux-foundation.org>
	<20080610112013.219fedda@core>
	<20080611112501.152da143.randy.dunlap@oracle.com> <20080612221046.4bbaef59@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alan Cox <alan@redhat.com>,
	jeff@garzik.org, Andrew Morton <akpm@linux-foundation.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:34866 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbYFLViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 17:38:08 -0400
In-Reply-To: <20080612221046.4bbaef59@lxorguk.ukuu.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- Original Message ---
> > drivers/built-in.o: In function `ne_block_output':
> > /local/linsrc/linux-2.6.26-rc5-mm2/drivers/net/ne2.c:751: undefined reference to `NS8390_init'
> > drivers/built-in.o: In function `ne2_probe1':
> > /local/linsrc/linux-2.6.26-rc5-mm2/drivers/net/ne2.c:502: undefined reference to `NS8390_init'
> > make[1]: *** [.tmp_vmlinux1] Error 1
> > 
> > for ne2 driver built into kernel image.
> 
> NS8390_init comes from drivers/net/8390.c for non pausing
> drivers. I
> thought something else might be needed as I was sure there was
> more to
> the origina patch I posted that didn't get out.
> 
> Do an s/NS8390_init/NS8390p_init/ in ne2.c


OK, that works.  Thanks.

---
~Randy

