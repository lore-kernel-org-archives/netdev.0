From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sun, 20 Apr 2008 03:55:15 -0700 (PDT)
Message-ID: <20080420.035515.12616544.davem@davemloft.net>
References: <1208176322.31695.73.camel@pmac.infradead.org>
	<20080419.183341.46125500.davem@davemloft.net>
	<1208688644.9212.407.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: dwmw2@infradead.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1208688644.9212.407.camel@pmac.infradead.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 20 Apr 2008 11:50:44 +0100

> Certainly, it's possible that we'll need _more_ criteria for udev to
> match on; that doesn't necessarily mean that dev_id shouldn't be one of
> them, does it?

I've read what you have to say, and your point is logical.

However you've just also stated that dev_id isn't even needed to solve
the particular problems you're interested in.

I'm not against exporting the value.  But let's do it because it does
solve a problem, not because it's fun to export every object instance
variable via sysfs :-)
