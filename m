From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: avoid unused variable warning
Date: Tue, 1 Dec 2015 16:48:59 +0900
Message-ID: <20151201074859.GA22945@verge.net.au>
References: <9616810.SPqCgIbKt5@wuerfel>
 <alpine.LFD.2.11.1511302242210.1918@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Wensong Zhang <wensong@linux-vs.org>,
	lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1511302242210.1918@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 10:48:34PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 30 Nov 2015, Arnd Bergmann wrote:
> 
> > When CONFIG_PROC_FS is disabled, the local 'net' variable in
> > ip_vs_app_net_init becomes unused, as gcc warns:
> > 
> > net/netfilter/ipvs/ip_vs_app.c: In function 'ip_vs_app_net_init':
> > net/netfilter/ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
> > 
> > This removes the line by moving the pointer dereference into the
> > user of the variable.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied to ipvs-next.
