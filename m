From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing
	ndo_uninit()
Date: Sat, 8 Apr 2017 16:49:38 +0300
Message-ID: <20170408134938.GA28955@splinter>
References: <20170408114159.12722-1-idosch@mellanox.com>
	<20170408114159.12722-2-idosch@mellanox.com>
	<20170408093042.20b08c5d@plumbers-lap.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cera@cera.cz, mlxsw@mellanox.com, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org, peter@svinota.eu,
	bridge@lists.linux-foundation.org, idosch@mellanox.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170408093042.20b08c5d@plumbers-lap.home.lan>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote:
> On Sat, 8 Apr 2017 14:41:58 +0300
> <idosch@mellanox.com> wrote:
> 
> >  static void br_dev_free(struct net_device *dev)
> >  {
> > -	struct net_bridge *br = netdev_priv(dev);
> > -
> > -	free_percpu(br->stats);
> >  	free_netdev(dev);
> >  }
> >  
> 
> Since the only thing left is free_netdev, you can now just set dev->destructor
> to be free_netdev.

Fine.

Beside stylistic issues, I would appreciate comments on how this should
be handled. Are we reverting the patch in the Fixes line or applying
this patchset?

I prefer the first option. Then after net is merged into net-next I can
re-post this patchset with the requested changes.
