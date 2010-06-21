From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: linux-next: manual merge of the tip tree with the net tree
Date: Mon, 21 Jun 2010 10:30:11 -0700
Message-ID: <20100621173011.GH2354@linux.vnet.ibm.com>
References: <20100621161609.935d0085.sfr@canb.auug.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100621161609.935d0085.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 21, 2010 at 04:16:09PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the tip tree got a conflict in
> net/bridge/br_fdb.c net/bridge/netfilter/ebt_redirect.c
> net/bridge/netfilter/ebt_ulog.c net/bridge/netfilter/ebtables.c
> net/netfilter/nfnetlink_log.c between commit
> f350a0a87374418635689471606454abc7beaa3a ("bridge: use rx_handler_data
> pointer to store net_bridge_port pointer") from the net tree and commit
> 81bdf5bd7349bd4523538cbd7878f334bc2bfe14 ("net: Make accesses to
> ->br_port safe for sparse RCU") from the tip tree.
> 
> The net tree commit looks like a superset of the tip tree commit, so I
> effectively reverted the tip tree commit.

I defer to Jiri on this one, and will withdraw my patch.

							Thanx, Paul

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/
