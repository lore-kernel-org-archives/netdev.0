From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 12:56:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com>
 <40A26FFA.4030701@pobox.com>            <20040512193349.GA14936@elte.hu>
 <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jgarzik@pobox.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 May 2004 Valdis.Kletnieks@vt.edu wrote:

> On Wed, 12 May 2004 21:33:49 +0200, Ingo Molnar said:
> > 
> > * Jeff Garzik <jgarzik@pobox.com> wrote:
> > 
> > > >Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
> > > >says:
> > > >	# define JIFFIES_TO_MSEC(x)     (x)
> > > >	# define MSEC_TO_JIFFIES(x)     (x)
> > > >
> > > >Is not correct.  Look at kernel/sched.c for verification of this :)
> > > 
> > > 
> > > Yes, that is _massively_ broken.
> > 
> > why is it wrong?
> 
> If the kernel jiffie is anything other than exactly 1 msec, you're screwed... 

I believe they were talking about include/asm-i386/param.h
                                          ^^^^^^^^


- Davide
