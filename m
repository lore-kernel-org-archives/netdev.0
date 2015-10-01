From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [regression] 6ae459bd skbuff: Fix skb checksum flag on skb pull
Date: Thu, 1 Oct 2015 16:42:22 +0800
Message-ID: <20151001084222.GA25104@gondor.apana.org.au>
References: <1443686148.2726.6.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443686148.2726.6.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Galbraith <umgwanakikbuti@gmail.com> wrote:
> 
> homer:/usr/local/src/kernel/linux-3.x.git # time strace -vvvfFtT git remote update 2> /strace.out
> Fetching origin
> 
> real    2m9.164s
> user    0m1.616s
> sys     0m0.316s
> 
> 2 minutes of thumb twiddling should have been..
> 
> homer:/usr/local/src/kernel/linux-3.x.git # time git remote update
> Fetching origin
> 
> real    0m0.213s
> user    0m0.156s
> sys     0m0.036s
> 
> Daemon runs as user git like so, with all repositories living in ~git:
> /usr/lib/git/git-daemon --syslog --detach --reuseaddr --user=git --group=daemon --pid-file=/var/run/git-daemon.pid --export-all --user-path
> 
> Bisected and post bisect verified by applying/removing a revert.

So do you use VXLANs?

If this patch is indeed causing the regression you should be able
to spot some differences in the tcpdump.  Can you confirm this?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
