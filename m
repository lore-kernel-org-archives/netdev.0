From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]: r8169: Message level support
Date: Mon, 28 Feb 2005 00:52:10 +0100
Message-ID: <20050227235210.GA27271@electric-eye.fr.zoreil.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com> <42224CF5.5090601@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <42224CF5.5090601@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> >3 - If PFX is included, we'll have a mix of printk and dprintk. My personal
> >    taste would be to not include it in the definition of the macro.
> 
> I'll go with Jeff here, which is that "PFX should only be used in probe 
> paths".

Fine.

[...]
> I think I did that for consistency with another printk that was split 
> across lines.

They were split when they could not fit on a single line. OTOH I did not
hunt them when they were already there.

[...]
> >Use dprintk ?
> 
> Original dprintk or the DPRINTK used in my patch? If you mean DPRINTK, 

Your.

> then it wouldn't work, because DPRINTK includes dev->name. At this point 
> in the code, dev->name is not defined.
> 
> Perhaps I could modifying DPRINTK (*) to use dev->name if defined, 
> otherwise fall back on PFX.

I would put the smallest amount of things behind dprintk() so it can be
used anywhere (for consistency): no PFX, no dev->name.

Thanks for your work.

--
Ueimor
