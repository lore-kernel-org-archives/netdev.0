From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Tue, 04 Sep 2012 01:34:39 -0400 (EDT)
Message-ID: <20120904.013439.2021598820983096971.davem@davemloft.net>
References: <20120824.151008.248026066556198861.davem@davemloft.net>
	<503922C0.7000707@chelsio.com>
	<50458DF4.1030907@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, netdev@vger.kernel.org, chethan@chelsio.com
To: naresh@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <50458DF4.1030907@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Naresh Kumar Inna <naresh@chelsio.com>
Date: Tue, 4 Sep 2012 10:43:24 +0530

> Removing all the module parameters from the driver would put us at a
> disadvantage with respect to tuning the driver and hardware. I have not
> not been able to find alternatives, considering every other driver uses
> module parameters. Could you provide pointers to the generic kernel
> facilities you mentioned in your last post?

Adding module parameters is a cop-out.  It's what you do if you want
to put zero effort into providing good interfaces for your driver.

If an appropriate generic mechanism doesn't exist yet, you simply add
one.

When people add crazy module parameter knobs to networking drivers, we
ask them to extend either ethtool or netlink, as appropriate.
