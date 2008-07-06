From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 17/18] net: add netif_napi_del
 function to allow for removal of napistructs
Date: Sat, 05 Jul 2008 21:14:30 -0700 (PDT)
Message-ID: <20080705.211430.83776216.davem@davemloft.net>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
	<20080627180200.22428.70787.stgit@localhost.localdomain>
	<486E1AB1.30902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <486E1AB1.30902@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 Jul 2008 08:42:25 -0400

> Jeff Kirsher wrote:
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> > +/**
> > + *  netif_napi_del - remove a napi context
> > + *  @napi: napi context
> > + *
> > + *  netif_napi_del() removes a napi context from the network device napi list
> > + */
> > +static inline void netif_napi_del(struct napi_struct *napi)
> > +{
> > +#ifdef CONFIG_NETPOLL
> > +	list_del(&napi->dev_list);
> > +#endif
> > +}
> > +
> 
> David - ACK?
> 
> I would prefer to throw this in with the 18-patch igb pile, if that's OK 
> with you.

Fine with me.

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
