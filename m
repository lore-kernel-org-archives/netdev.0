From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3 3/3] net: netprio: fix cgrp create and write
 priomap race
Date: Thu, 16 Aug 2012 15:11:56 -0700 (PDT)
Message-ID: <20120816.151156.967092597887492349.davem@davemloft.net>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
	<20120814223435.3551.62387.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
To: john.r.fastabend@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814223435.3551.62387.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 14 Aug 2012 15:34:35 -0700

> A race exists where creating cgroups and also updating the priomap
> may result in losing a priomap update. This is because priomap
> writers are not protected by rtnl_lock.
> 
> Move priority writer into rtnl_lock()/rtnl_unlock().
> 
> CC: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
