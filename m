From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 20:23:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE54F4D.50909@candelatech.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca> <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca> <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:

> Initially I was looking for tulip cards but almost nobody is producing
> them any more.  Almost a year ago I came across the following list, which
> is why I went with the 3com (at the time it indicated rx/tx irqmit for the
> 3com, until I emailed the author that I found out it was tx only)
> http://www.fefe.de/linuxeth/

If you want 4-port tulip NICs, I've had decent luck with the Phobox p430tx
NICs ($350 or so per NIC, so not cheap).  That said, the e1000s are definately
better as far as my own testing has been concerned.  (I'm doing packet pushing
& reception, no significant routing, though).

One waring about e1000's, make sure you have active airflow across the NICs
if you put two together.  Otherwise, buy a dual port NIC...it has a single
chip and you will have less cooling issues.

Ben


> 
> I had joined the vortex list last fall looking for some tips and that
> didn't help much (other than telling me that the 3com wasn't the best
> choice).  I've since bought a couple tg3 and a bunch of e1000 cards that
> I'm planning to put into production.
> 
> Rob's test results seem to show that even if I replace my 3c905cx cards
> with e1000's I'll still get killed with a 50kpps synflood with my current
> CPU.  Upgrading to dual 2Ghz CPUs is not a preferred solution since I
> can't do that in a 1U rack-mount box.  Yeah, I could probably do it with
> water cooling, but that's not an option in a telco hotel like 151 Front
> St. (Toronto).
> 
> A couple weeks ago I got one of my techs to test freeBSD/polling with full
> routing tables on a 1Ghz celeron and 2 e1000 cards.  His testing seems to
> suggest it will handle a 50kpps synflood DOS.  It would be nice if Linux
> could do the same.
> 
> Despite the BSD bashing (to be expected on a Linux list, I guess), I will
> be using BSD as well as Linux for core routing.  The plan is 1 linux
> router and 1 bsd router each running zebra, connected to separate upstream
> transit providers, running ibgp between them, and both advertising a
> default route into OSPF.  Then if I get hit with a DOS that kills Linux,
> the BSD box will have a much better chance of staying up than if I just
> used a second Linux box for redundancy.  If the BSD boxes turn out to have
> twice the performance of the linux boxes, it may be better for me to dump
> linux for routing altogether. :-(
> 
> -Ralph
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
