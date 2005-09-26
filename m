From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Mon, 26 Sep 2005 07:18:12 -0400
Message-ID: <1127733492.6215.274.camel__3283.00055484778$1127734011$gmane$org@localhost.localdomain>
References: <200509260445.46740.mbellion@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion <mbellion@hipac.org>
In-Reply-To: <200509260445.46740.mbellion@hipac.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-26-09 at 04:45 +0200, Michael Bellion wrote:
> Hi
> 
> I am happy to announce the release of nf-HiPAC version 0.9.0
> 
> During the development of version 0.9.0 everything was ported to Linux kernel 
> 2.6 and large parts of the kernel code have been rewritten.
> The kernel patch is now fairly non-intrusive: it only adds one simple function 
> to ip_tables.c. The rest of the patch introduces new files to the kernel. 
> The new release fixes all known bugs and also introduces some new features.
> 
> Since the last release I have become part of MARA Systems AB 
> ( http://www.marasystems.com ). MARA Systems AB is now the commercial backer 
> of the HiPAC Project and finances it completely. Together MARA Systems and I 
> will make sure that HiPAC is actively maintained and further developed under 
> the GNU GPL.
> 
> 

Congratulations to yourself as well as your sponsor. I think this is
useful. 

The iptables wrapper is certainly valuable. 

Can you post some numbers relative to iptables? 
Some tests with the following parameters would be helpful:
- Variable incoming packet rate (in packets per second)
- Variable packet sizes
- Variable number of users/filters
- Effect of adding/removing/modifying policies while under different
incoming traffic rates.

Just even simple non-stateful comparisons like i did with tc over here:

http://www.suug.ch/sucon/04/slides/pkt_cls.pdf

Or even better when you do these tests also try out with tc filter.

cheers,
jamal
