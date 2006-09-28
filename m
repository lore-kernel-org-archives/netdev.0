From: cagri coltekin <cagri@ripe.net>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Thu, 28 Sep 2006 10:40:18 +0200
Message-ID: <20060928084018.GA15141@ripe.net>
References: <20060827142347.GA20092@ripe.net> <E1GHUoC-0007Tn-00@gondolin.me.apana.org.au> <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net> <20060928003829.GA8952@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:41155 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S1751784AbWI1IkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 04:40:20 -0400
To: Herbert Xu <herbert.xu@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060928003829.GA8952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 10:38:29AM +1000, Herbert Xu wrote:
> On Tue, Sep 26, 2006 at 01:21:22PM +0200, cagri coltekin wrote:
> >
> > ------------------------------------------------------------------------------
> > [ 1395.890897] ------------[ cut here ]------------
> > [ 1395.946093] kernel BUG at net/ipv6/ip6_output.c:940!
> 
> Could you go further back in the logs to see if there was a
> warning message? Either that or turn the WARN_ON into a BUG.

No. Bug is the first after boot:

[   34.042841] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   44.110469] eth0: no IPv6 routers present
[   80.968012] process `syslogd' is using obsolete setsockopt SO_BSDCOMPAT
[   81.452248] process `named' is using obsolete setsockopt SO_BSDCOMPAT
[  110.559560] process `lwresd' is using obsolete setsockopt SO_BSDCOMPAT
[  140.568831] process `named' is using obsolete setsockopt SO_BSDCOMPAT
[ 1395.890897] ------------[ cut here ]------------
[ 1395.946093] kernel BUG at net/ipv6/ip6_output.c:940!
[ 1396.005441] invalid opcode: 0000 [#1]

Cheers,
-- 
cagri
