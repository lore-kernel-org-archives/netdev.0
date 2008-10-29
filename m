From: Joe Perches <joe@perches.com>
Subject: [ofa-general] Re: [PATCH] infiniband: Add struct in6_addr addr to
	union ib_gib
Date: Tue, 28 Oct 2008 23:58:40 -0700
Message-ID: <1225263521.5269.273.camel@localhost>
References: <ada8ws8mi8x.fsf@cisco.com> <1225236128.5269.240.camel@localhost>
	<1225239374.5269.251.camel@localhost>
	<20081028.223941.18931166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	sean.hefty@intel.com, harvey.harrison@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20081028.223941.18931166.davem@davemloft.net>
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

On Tue, 2008-10-28 at 22:39 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 28 Oct 2008 17:16:14 -0700
> > ib_gid's can be print'd using the new %p6 facility
> > Signed-off-by: Joe Perches <joe@perches.com>
> Joe, please provide something relative to Harvey's patches
> so that this new union member gets passed into the %p6
> uses.

Sure.  After Harvey's patches show up in
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=summary
I'll make a patchset including this union ib_gid addition as
well as changes to drivers/infiniband/

Roland, in a separate question, are the infiniband maintainers
also the maintainers of include/rdma/?  If "F: patterns" ever
gets accepted into MAINTAINERS, should include/rdma/ be listed
under infiniband?

You and Sean Hefty seem to be the primary authors.

$ git log include/rdma/ | grep Author: | \
  sort | uniq -c | sort -nr | head -5
     32 Author: Sean Hefty <sean.hefty@intel.com>
     23 Author: Roland Dreier <rolandd@cisco.com>
      6 Author: Michael S. Tsirkin <mst@mellanox.co.il>
      5 Author: Or Gerlitz <ogerlitz@voltaire.com>
      4 Author: Jack Morgenstein <jackm@mellanox.co.il>
