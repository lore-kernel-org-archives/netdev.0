From: Daniele Venzano <webvenza@libero.it>
Subject: Re: sis900 oops on resume
Date: Fri, 19 Nov 2004 11:01:46 +0100
Message-ID: <20041119100146.GA26017@picchio.gall.it>
References: <20041117182403.GC2252@stro.at> <20041117201008.GA11439@elf.ucw.cz> <20041118021425.GA2128@stro.at> <20041118084431.GA13870@gateway.milesteg.arr> <20041118094602.GB2287@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: maximilian attems <janitor@sternwelten.at>
Content-Disposition: inline
In-Reply-To: <20041118094602.GB2287@stro.at>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2004 at 10:46:02AM +0100, maximilian attems wrote:
> On Thu, 18 Nov 2004, Daniele Venzano wrote:
> > I'm aware of this problem, sis900 looses the first interrupt after
> > resume, I have to check the code.
> > On my tests the card, after that lost interrupt, worked normally. Is
> > that your case, or do you have a non working sis900 after resume ?
> 
> well it works, as long as i do not use guessnet(8),
> as described in the bug report, but the lost interrupt is reported
> on every resume. 

Unfortunately I'm no longer able to reproduce this problem. I just tried
to suspend/resume with a running ping -f and I can't see any lost or
abnormal interrupts.

There is a noticeable delay after resume and before the NIC is on line
and able to handle traffic, but that is caused by the link
detection/autonegotiation and I can do little to speed things up.

Have you tried delaying the guessnet invocation ?

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
