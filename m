From: maximilian attems <janitor@sternwelten.at>
Subject: Re: sis900 oops on resume
Date: Thu, 18 Nov 2004 10:46:02 +0100
Message-ID: <20041118094602.GB2287@stro.at>
References: <20041117182403.GC2252@stro.at> <20041117201008.GA11439@elf.ucw.cz> <20041118021425.GA2128@stro.at> <20041118084431.GA13870@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Pavel Machek <pavel@ucw.cz>
Content-Disposition: inline
In-Reply-To: <20041118084431.GA13870@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Daniele Venzano wrote:

> On Thu, Nov 18, 2004 at 03:14:25AM +0100, maximilian attems wrote:
> > On Wed, 17 Nov 2004, Pavel Machek wrote:
> > > > happens since the use of guessnet,
> > > > guessnet is based on divine and sends arp requests to network.
> > > > network was down after the oops, but beside resume system worked.
> > > 
> > > And where do you see the oops? Irq 10 does not work, that's only
> > > backtrace. Fix the sis900 driver...
> >
> > ok, i'm not that familiar with suspend pathes,
> > what's going wrong in sis900_resume() or sis900_suspend()?
> 
> I'm aware of this problem, sis900 looses the first interrupt after
> resume, I have to check the code.
> On my tests the card, after that lost interrupt, worked normally. Is
> that your case, or do you have a non working sis900 after resume ?

well it works, as long as i do not use guessnet(8),
as described in the bug report, but the lost interrupt is reported
on every resume. 

--
maks
