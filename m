From: "ira.weiny" <ira.weiny@intel.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp() for, iwarp-check
Date: Fri, 27 Mar 2015 13:16:31 -0400
Message-ID: <20150327171631.GC27862@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wang <yun.wang@profitbricks.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
	Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bart Van Assche <bvanassche@acm.org>,
	Yann Droneaud <ydroneaud@opteya.com>,
	Colin Ian King <colin.king@canonical.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Matan Barak <matanb@mellanox.com>,
	Alex Estrin <alex.
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150327161319.GB28412@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 10:13:19AM -0600, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 04:47:36PM +0100, Michael Wang wrote:
> > 
> > Introduce helper has_iwarp() to help us check if an IB device
> > support IWARP protocol.
> 
> Should probably be !has_rdma_read_sges()
> 
> True if the device can handle more than one SGE entry on a RDMA READ
> work request.

Isn't this value already provided by the query_device verb?

The verbs spec states the Query HCA contains the:

"Maximum number of scatter/gather entries per Work Request supported by the
HCA."

-- Ira

> 
> Jason
