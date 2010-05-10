From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 10 May 2010 18:27:55 +0200
Message-ID: <4BE8340B.901@trash.net>
References: <1272865436.2173.182.camel@edumazet-laptop>	<20100502.225509.233880079.davem@davemloft.net>	<4BE8290A.2080707@trash.net> <20100510.091257.51273494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Valdis.Kletnieks@vt.edu,
	akpm@linux-foundation.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100510.091257.51273494.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 10 May 2010 17:40:58 +0200
> 
>> I queued this patch in nf-next, the only reason why I haven't
>> submitted it yet is that I was unable to get git to cleanly export
>> only the proper set of patches meant for -next due to a few merges,
>> it insists on including 5 patches already merged upstream. If you
>> don't mind ignoring the first 5 patches in the series, I'll send a
>> pull request tonight.
> 
> Something like "git format-patch origin" doesn't avoid those upstream
> commits?  Weird...

Yeah, it seems to have something to do with me merging the nf-2.6.git
tree a few weeks ago since it had patches queued that were too late
for 2.6.34. Even the --ignore-if-in-upstream option doesn't help.

> Another trick is to specify a commit range using triple-dot "..."
> notation, such as "origin...master"

Thanks, I'll give it another try, the alternative is manually
renumbering the entire patchset.
