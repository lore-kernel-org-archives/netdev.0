From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/8]
 ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Fri, 23 Nov 2007 18:04:58 -0800
Message-ID: <20071123180458.ad3bd98e.akpm@linux-foundation.org>
References: <200711212302.lALN2tJG013658@imap1.linux-foundation.org>
	<4747855B.5060606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Emilian.Medve@Freescale.com,
	davem@davemloft.net, galak@gate.crashing.org, leoli@Freescale.com,
	paulus@samba.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37700 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753012AbXKXCFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 21:05:50 -0500
In-Reply-To: <4747855B.5060606@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Nov 2007 20:58:51 -0500 Jeff Garzik <jeff@garzik.org> wrote:

> akpm@linux-foundation.org wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Emil Medve <Emilian.Medve@Freescale.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: Kumar Gala <galak@gate.crashing.org>
> > Cc: Li Yang <leoli@freescale.com>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/ucc_geth.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -puN drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes drivers/net/ucc_geth.c
> > --- a/drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
> > +++ a/drivers/net/ucc_geth.c
> > @@ -3443,7 +3443,7 @@ static int ucc_geth_rx(struct ucc_geth_p
> >  	u16 length, howmany = 0;
> >  	u32 bd_status;
> >  	u8 *bdBuffer;
> > -	struct net_device * dev;
> > +	struct net_device *dev;
> 
> ACK with a fixed description...
> 

Well...  I do these little fixups

a) to remind originators that they should be checking their stuff with
checkpatch

b) to fold into the offending base patch prior to sending upstream

c) to let upstream (in this case you) know that the patch had coding-style
problems.

as it appears that you merged the base patch without noticing the error,
and without running checkpatch I don't think it's worth merging a silly
one-liner like this on its own.


