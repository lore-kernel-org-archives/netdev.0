From: Maxim <maximlevitsky@gmail.com>
Subject: Re: Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume
Date: Sun, 18 Feb 2007 15:43:53 +0200
Message-ID: <200702181543.53296.maximlevitsky@gmail.com>
References: <200702152253.53680.maximlevitsky@gmail.com> <200702180029.03651.maximlevitsky@gmail.com> <20070217225215.GE14222@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751118AbXBRNoA@vger.kernel.org>
In-Reply-To: <20070217225215.GE14222@elf.ucw.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 18 February 2007 00:52:15 Pavel Machek wrote:
> Hi!
> > 
> > Hello ,  I am sorry that I missed some parts of coding style. I need to reread it :-)
> > 
> > There is a updated patch :
> 
> It looks better.
> 
> > +	/* Disable Interrupt */
> > +	outl (0, dev->base_addr + DCR7);
> > +	outl (inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
> 
> I'd kill space after outl...
> 
> > +	/* Free RX buffers */
> > +	dmfe_free_rxbuffer(db);
> > +
> > +	/* Power down device*/
> 
> and add space before */.
> 
> Congratulation, you passed coding-style-police-check ;-).
> 									Pavel
> 

Hello,
	Thanks for reply, I just want to ask one question:

	Those patches are now merged in -mm, and I noticed that Andrew Morton after applying them did fix my bad coding style and check for CONFIG_PM=n that I didn't include

	Now should I resend two last patches or not ?


Regards, Maxim Levitsky


PS:  Actualy I have planned to send those patches a little bit later , and do more checks like the coding style stuff, mailer problems, etc... 
but I noticed that 2.6.20 breaks link detection on my card,
and I even saw report here on LKML about that, so I decided to send them now

Of cource I did check them for code correctness , and I actualy used them for about a month.
I tried to do as little as possible changes, and verify each line.
