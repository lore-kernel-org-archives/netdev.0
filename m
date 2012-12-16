From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: nf_nat: Also handle non-ESTABLISHED
 routing changes in MASQUERADE
Date: Sun, 16 Dec 2012 23:33:33 +0100
Message-ID: <20121216223333.GB1304@1984>
References: <1355358229-25167-1-git-send-email-bsderandrew@gmail.com>
 <alpine.DEB.2.00.1212130918410.2048@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1212130918410.2048@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 13, 2012 at 09:19:27AM +0100, Jozsef Kadlecsik wrote:
> On Wed, 12 Dec 2012, Andrew Collins wrote:
> 
> > The MASQUERADE target now handles routing changes which affect
> > the output interface of a connection, but only for ESTABLISHED
> > connections.  It is also possible for NEW connections which
> > already have a conntrack entry to be affected by routing changes.
> > 
> > This adds a check to drop entries in the NEW+conntrack state
> > when the oif has changed.
> > 
> > Signed-off-by: Andrew Collins <bsderandrew@gmail.com>
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks guys.
