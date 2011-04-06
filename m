From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/24] sysctl: net: call unregister_net_sysctl_table
 where needed
Date: Wed, 06 Apr 2011 12:52:56 -0700 (PDT)
Message-ID: <20110406.125256.102558618.davem@davemloft.net>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
	<cover.1301711868.git.lucian.grijincu@gmail.com>
	<05ae3c2fdd2db1f6a2fd3cd900164667e615f4f8.1301711868.git.lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, ebiederm@xmission.com, tavi@cs.pub.ro,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lucian.grijincu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <05ae3c2fdd2db1f6a2fd3cd900164667e615f4f8.1301711868.git.lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Sat,  2 Apr 2011 04:53:15 +0200

> ctl_table_headers registered with register_net_sysctl_table should
> have been unregistered with the equivalent unregister_net_sysctl_table
> 
> Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>

Oops, hmmm...  Can this actually cause any real problems currently?

If so I'd like to toss this specific patch into net-2.6

Thanks.
