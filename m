From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH ] dynamic_debug: call __netdev_printk only for CONFIG_NET
Date: Thu, 1 Sep 2011 11:18:18 -0400
Message-ID: <20110901151817.GA14324@redhat.com>
References: <cover.1313085588.git.jbaron@redhat.com>
 <5514795fe63ccfd4b3a80283ed04a526abe3c59d.1313085588.git.jbaron@redhat.com>
 <201109011657.02407.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, joe@perches.com, jim.cromie@gmail.com,
	bvanassche@acm.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, aloisio.almeida@openbossa.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201109011657.02407.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 01, 2011 at 04:57:02PM +0200, Arnd Bergmann wrote:
> __netdev_printk is only defined when CONFIG_NET is set. Since we only need
> __dynamic_netdev_dbg for network drivers, we can make it conditional on the
> same Kconfig symbol.
>

Hi,

Yes, I've posted a fix for this:

https://lkml.org/lkml/2011/8/30/297

Hopefully, it will be pulled in soon.

Thanks,

-Jason 
