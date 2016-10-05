From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: error: 'struct net_device' has no member named
 'nf_hooks_ingress'
Date: Thu, 06 Oct 2016 06:11:26 +0900
Message-ID: <1475701886.28155.223.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160927164026.741b290b@canb.auug.org.au>
         <20160927100324.GA466@swordfish> <20161004004801.GA4661@swordfish>
         <87wphm1pn8.fsf@steelpick.2x.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Aaron Conole <aconole@bytheb.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
To: Michal Sojka <sojkam1@fel.cvut.cz>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <87wphm1pn8.fsf@steelpick.2x.cz>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-05 at 22:56 +0200, Michal Sojka wrote:

> this commit is now in mainline as
> e3b37f11e6e4e6b6f02cc762f182ce233d2c1c9d and it breaks my build:
> 
>     net/netfilter/core.c: In function 'nf_set_hooks_head':
>     net/netfilter/core.c:96:3: error: 'struct net_device' has no member named 'nf_hooks_ingress'
> 
> Are the fixes (see below) on the way to mainline too?

Yes the fixes are already in nf tree and _will_ get pushed.

Pablo and David are attending netdev 1.2 in Tokyo and have obligations.

https://git.kernel.org/cgit/linux/kernel/git/pablo/nf-next.git/

Thanks.
