From: Ingo Molnar <mingo@elte.hu>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 21:33:49 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040512193349.GA14936@elte.hu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265200AbUELTfa@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40A26FFA.4030701@pobox.com>
List-Id: netdev.vger.kernel.org


* Jeff Garzik <jgarzik@pobox.com> wrote:

> >Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
> >says:
> >	# define JIFFIES_TO_MSEC(x)     (x)
> >	# define MSEC_TO_JIFFIES(x)     (x)
> >
> >Is not correct.  Look at kernel/sched.c for verification of this :)
> 
> 
> Yes, that is _massively_ broken.

why is it wrong?

	Ingo
