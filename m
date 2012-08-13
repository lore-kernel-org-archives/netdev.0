From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Mon, 13 Aug 2012 03:30:55 +0100
Message-ID: <20120813023055.GA23464@ZenIV.linux.org.uk>
References: <20120813015348.GZ23464@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120813015348.GZ23464@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2012 at 02:53:48AM +0100, Al Viro wrote:
> 	if (old_priomap)
> 		memcpy(new_priomap->priomap, old_priomap,
					     ^^^^^^^^^^^
					     old_priomap->priomap,
that is.
