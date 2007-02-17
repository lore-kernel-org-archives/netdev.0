From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume
Date: Sat, 17 Feb 2007 23:52:15 +0100
Message-ID: <20070217225215.GE14222@elf.ucw.cz>
References: <200702152253.53680.maximlevitsky@gmail.com> <200702152311.54407.maximlevitsky@gmail.com> <20070217115029.GF9120@elf.ucw.cz> <200702180029.03651.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@kernel.org, linux-kernel@vger.kernel.org
To: Maxim <maximlevitsky@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933073AbXBQWwf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200702180029.03651.maximlevitsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
> 
> Hello ,  I am sorry that I missed some parts of coding style. I need to reread it :-)
> 
> There is a updated patch :

It looks better.

> +	/* Disable Interrupt */
> +	outl (0, dev->base_addr + DCR7);
> +	outl (inl(dev->base_addr + DCR5), dev->base_addr + DCR5);

I'd kill space after outl...

> +	/* Free RX buffers */
> +	dmfe_free_rxbuffer(db);
> +
> +	/* Power down device*/

and add space before */.

Congratulation, you passed coding-style-police-check ;-).
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
