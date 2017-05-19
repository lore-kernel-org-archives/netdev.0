From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix accounting of active ports in 3ad
Date: Fri, 19 May 2017 17:14:17 -0400 (EDT)
Message-ID: <20170519.171417.473208349438307952.davem@davemloft.net>
References: <20170517151144.57865-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517151144.57865-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Wed, 17 May 2017 11:11:44 -0400

> As of 7bb11dc9f59d and 0622cab0341c, bond slaves in a 3ad bond are not
> removed from the aggregator when they are down, and the active slave count
> is NOT equal to number of ports in the aggregator, but rather the number
> of ports in the aggregator that are still enabled.
 ...
> Remedy it by using the same logic introduced in
> 7bb11dc9f59d in __bond_3ad_get_active_agg_info(), so sysfs, procfs and
  ^^^^^^^^^^^^
> netlink all report the number of active ports.

I think you mean to reference commit 0622cab0341c here not 7bb11dc9f59d.
