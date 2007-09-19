From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Wed, 19 Sep 2007 08:19:08 +0200
Message-ID: <20070919061908.GA31331@mellanox.co.il>
References: <adahclymos8.fsf@cisco.com>
	<200709180909.50029.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <200709180909.50029.jackm@dev.mellanox.co.il>
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

> Missing from this list (IMPORTANT patch!):
> [ofa-general] [PATCH 2 of 2] IB/mlx4: Handle new FW requirement for send request prefetching, for WQE sg lists
> (Posted by me to list on Sept 4)
> {patch header: 
> This is an addendum to Roland's commit 0e6e74162164d908edf7889ac66dca09e7505745
> (June 18). This addendum adds prefetch headroom marking processing for s/g segments.
> 
> We write s/g segments in reverse order into the WQE, in order to guarantee
> that the first dword of all cachelines containing s/g segments is written last
> (overwriting the headroom invalidation pattern). The entire cacheline will thus
> contain valid data when the invalidation pattern is overwritten.

This actually looks like a bugfix that might even have been appropriate
for 2.6.23. Roland, do you have this patch? Can you comment on it please?

-- 
MST
