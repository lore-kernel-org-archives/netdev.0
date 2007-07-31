From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB
	support for	the bonding driver
Date: Tue, 31 Jul 2007 17:22:35 +0300
Message-ID: <20070731142234.GC16015@mellanox.co.il>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>
	<46AF3CA8.6050201@gmail.com>
	<20070731140436.GA16015@mellanox.co.il>
	<46AF44E0.50700@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>, fubar@us.ibm.com,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org, davem@davemloft.net
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <46AF44E0.50700@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

> Quoting Or Gerlitz <ogerlitz@voltaire.com>:
> Subject: Re: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support for?the bonding driver
> 
> Michael S. Tsirkin wrote:
> >Maybe we could use hard_header_cache/header_cache_update methods instead of
> >neighbour cleanup calls.
> 
> >To do this, it is possible that we'll have to switch from storing pointers
> >inside the neighbour to keeping an index there, but I expect the
> >performance impact to be minimal.
> >
> >As a result, bonding would not have to copy pointers into ipoib module
> >and module removal would get fixed.
> 
> To be precise, bonding will copy all the symbols it copies today from 
> the slave module (ipoib),
> see bond_setup_by_slave() in patch 3/7, except 
> for the neighbour cleanup callback which is copied through coping the 
> neigh_setup function.

Not really.
This copying of symbols is something that you added, isn't it?
So with this approach, it won't be needed.

It's always wrong to copy symbols from another module without
referencing it.
-- 
MST
