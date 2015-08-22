From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 net-next] netfilter: ipset: Fixing unnamed union init
Date: Sat, 22 Aug 2015 20:44:48 +0200
Message-ID: <20150822184448.GA3610@salvia>
References: <1440222251-21132-1-git-send-email-eladr@mellanox.com>
 <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netfilter-devel@vger.kernel.org,
	Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Vinson Lee <vlee@twopensource.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Akemi Yagi <amyagi@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508222006570.13403@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc'ing Andrew, since he's got a similar patch in mmotm [1].

On Sat, Aug 22, 2015 at 08:11:18PM +0200, Jozsef Kadlecsik wrote:
> On Sat, 22 Aug 2015, Elad Raz wrote:
> 
> > In continue to proposed Vinson Lee's post [1], this patch fixes compilation
> > issues founded at gcc 4.4.7. The initialization of .cidr field of unnamed
> > unions causes compilation error in gcc 4.4.x.
> 
> There's already a (couple of weeks old) patch in the -mm tree to fix the 
> gcc compatilibity issue, see the last comment in the thread you refer to:
> 
> > Visible links
> > [1] https://lkml.org/lkml/2015/7/5/74
> 
> So I'm unsure whether a new patch should be submitted for this.

I'll take this patch so this follows the usual path through David's
net tree. IIRC, duplicates get automatically dropped from the mmotm
tree.

[1] http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/commit/?id=18b386426ff0a90e405c962ec8f51ea70e7df637

I'll wait for some little time just in case someone raises any
concern.

Thanks!
