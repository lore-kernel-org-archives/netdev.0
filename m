From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib()
 and, cap_ipoib() for ipoib-check
Date: Fri, 27 Mar 2015 10:38:57 -0600
Message-ID: <20150327163857.GE28412@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
 <55157BC6.70400@profitbricks.com>
 <20150327160616.GA28412@obsidianresearch.com>
 <5515822E.2020207@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
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
	Alex Estrin <alex.estrin@int
To: Michael Wang <yun.wang@profitbricks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5515822E.2020207@profitbricks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 27, 2015 at 05:15:42PM +0100, Michael Wang wrote:

> I'm not sure if it's a good idea, but seems like the idea is use twice
> check on different level to save some cycles?

That is what it looks like to me, right now. Which is why I'd drop
it. This isn't performance sensitive, make it simple.

Jason
