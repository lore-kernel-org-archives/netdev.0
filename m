From: Song Wang <wsonguci@yahoo.com>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: Wed, 15 Sep 2004 11:06:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915180603.98079.qmail@web40007.mail.yahoo.com>
References: <1094868693.1041.86.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1094868693.1041.86.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The mips CPU on the board is MIPS32 compatible.
I don't think it's NAPI based.

The gettimeofday patch you mentioned came into
the 2.6 kernel at what version?

Do you think it's related to HZ change from 100
to 1000? Actually I did change HZ back to 100,
but it didn't help.

-Song


--- jamal <hadi@cyberus.ca> wrote:

> 
> What mips board is this? NAPI based?
> I would say that you should get higher numbers with
> 2.6.x.
> Are you running any sort of apps that need
> gettimeofday?
> I have certainly seen higher numbers on 2.6 vs 2.4
> starting at some
> point where Andis gettimeofday patch went in - but
> this was on x86.
> 
> cheers,
> jamal
> 
> On Fri, 2004-09-10 at 20:52, Song Wang wrote:
> > Hi,
> > 
> > I'm looking for the network packet routing
> > performance comparison between the latest 2.4
> > and 2.6 kernel.
> > 
> > I did some initial testing on my mips-based
> router.
> > 2.6 kernel (2.6.8.1) performed way below 2.4
> kernel
> > (2.4.17). It sucks. Turning on preemption on 2.6 
> > kernel even makes routing performance worse.
> > 
> > Anybody did a comprehensive study on the routing
> > performance for 2.6 and 2.4 kernel?
> > 
> > Thanks.
> > 
> > 
> > 		
> > __________________________________
> > Do you Yahoo!?
> > Y! Messenger - Communicate in real time. Download
> now. 
> > http://messenger.yahoo.com
> > 
> > 
> 
> 



		
_______________________________
Do you Yahoo!?
Declare Yourself - Register online to vote today!
http://vote.yahoo.com
