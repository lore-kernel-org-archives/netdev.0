From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [KJ] [PATCH] he: tiny space savings
Date: Sun, 17 Dec 2006 21:06:25 +0100
Message-ID: <20061217200625.GE10316@stusta.de>
References: <20061217125622.GA4973@martell.zuzino.mipt.ru> <20061217182806.GD10316@stusta.de> <20061217200255.GA5236@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Andi Drebes <webmaster@programmierforen.de>,
	kernel-janitors@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:3122 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751176AbWLQUGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 15:06:25 -0500
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20061217200255.GA5236@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 17, 2006 at 11:02:55PM +0300, Alexey Dobriyan wrote:
> On Sun, Dec 17, 2006 at 07:28:06PM +0100, Adrian Bunk wrote:
> > On Sun, Dec 17, 2006 at 03:56:22PM +0300, Alexey Dobriyan wrote:
> > > From: Andi Drebes <webmaster@programmierforen.de>
> > >    text    data     bss     dec     hex filename
> > >   20015     480      28   20523    502b drivers/atm/he.o
> > >   19997     480      28   20505    5019 drivers/atm/he.o
> > >
> > > Signed-off-by: Andi Drebes <webmaster@programmierforen.de>
> > > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > > ---
> > >
> > >  drivers/atm/he.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > >
> > > --- a/drivers/atm/he.c
> > > +++ b/drivers/atm/he.c
> > > @@ -101,7 +101,7 @@ #endif /* HE_DEBUG */
> > >
> > >  /* version definition */
> > >
> > > -static char *version = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
> > > +static const char version[] = "$Id: he.c,v 1.18 2003/05/06 22:57:15 chas Exp $";
> > >...
> >
> > Can't we kill this ancient and outdated version string instead?
> 
> "version" is involved in he_proc_read(). I think, no.

You don;t have to omit this line, but printing a more than 3 years old 
CVS tag is silly (I can't believe anyone is parsing the CVS version).

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

