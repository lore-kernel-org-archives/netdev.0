From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 12:49:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com>
 <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
        Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512193349.GA14936@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 May 2004, Ingo Molnar wrote:

> 
> * Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > >Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
> > >says:
> > >	# define JIFFIES_TO_MSEC(x)     (x)
> > >	# define MSEC_TO_JIFFIES(x)     (x)
> > >
> > >Is not correct.  Look at kernel/sched.c for verification of this :)
> > 
> > 
> > Yes, that is _massively_ broken.
> 
> why is it wrong?

For HZ == 1000 it's fine, even if it'd better to explicitly make it HZ 
dependent and let the compiler to discard them.



- Davide
