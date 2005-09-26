From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Mon, 26 Sep 2005 09:31:37 -0400
Message-ID: <1127741497.6215.345.camel__16632.8673171394$1127741707$gmane$org@localhost.localdomain>
References: <200509260445.46740.mbellion@hipac.org>
	 <1127733492.6215.274.camel@localhost.localdomain>
	 <200509261516.16565.mbellion@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion <mbellion@hipac.org>
In-Reply-To: <200509261516.16565.mbellion@hipac.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-26-09 at 15:16 +0200, Michael Bellion wrote:
> Hi,
> 
> > Can you post some numbers relative to iptables?
> 
> We have some performance tests available at:
> http://www.hipac.org/performance_tests/overview.html
> 
> We also have a list of the independent performance tests we know of:
> http://www.hipac.org/performance_tests/independent.html
> 

Can you please post something against new kernels you are patching
against _today_? I recall these same graphs from a few years back but
even iptables has improved since. 
Any issues you may find can only help you improve.

BTW, your tests were unfair to iptables; you should have had optimized
the rules with the assumption that someone needing that many rules would
probably have needed to do some optimization even with iptables.
Yes, it would only have taken one year to load 256K rules, but it would
have loaded eventually.

> > Some tests with the following parameters would be helpful:
> > - Variable incoming packet rate (in packets per second)
> > - Variable packet sizes
> > - Variable number of users/filters
> > - Effect of adding/removing/modifying policies while under different
> > incoming traffic rates.
> 
> Most of this parameters are used in the performance tests above.
> 
> The effect of adding/removing/modifying policies while under different
> incoming traffic rates has not been tested in the above tests.
> 
> nf-HiPAC is based on a completely dynamic approach.

Very good. Please do more up to date testing and try to include tc
filter as well.

cheers,
jamal
