From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost net-next] ethtool: future-proof interface for
 speed extensions
Date: Thu, 11 Feb 2016 09:52:30 -0500 (EST)
Message-ID: <20160211.095230.1496512087910445182.davem@davemloft.net>
References: <1454880301-20984-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	andrew@lunn.ch, richardcochran@gmail.com, amirv@mellanox.com,
	hadarh@mellanox.com, hariprasad@chelsio.com,
	jacob.e.keller@intel.com, parav.pandit@avagotech.com,
	john.r.fastabend@intel.com, razor@blackwall.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454880301-20984-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 7 Feb 2016 23:27:55 +0200

> Many virtual and not quite virtual devices allow any speed to be set
> through ethtool. In particular, this applies to the virtio-net devices.
> Document this fact to make sure people don't assume the enum lists all
> possible values.  Reserve values greater than INT_MAX for future
> extension and to avoid conflict with SPEED_UNKNOWN.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks.
