From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] driver/net/benet: fix be_cmd_multicast_set()
 memcpy bug
Date: Wed, 08 Dec 2010 10:27:29 -0800 (PST)
Message-ID: <20101208.102729.115929908.davem@davemloft.net>
References: <20101206130059.GA19448@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg.marsden@oracle.com, guru.anbalagane@oracle.com
To: joe.jin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101206130059.GA19448@joejin-pc.cn.oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Jin <joe.jin@oracle.com>
Date: Mon, 6 Dec 2010 21:00:59 +0800

> Hi, 
> 
> Regarding  benet be_cmd_multicast_set() function, now using
> netdev_for_each_mc_addr() helper for mac address copy, but
> when copying to req->mac[] did not increase of the index.
> 
> Cc: Sathya Perla <sathyap@serverengines.com>
> Cc: Subbu Seetharaman <subbus@serverengines.com>
> Cc: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> Cc: Ajit Khaparde <ajitk@serverengines.com>
> Signed-off-by: Joe Jin <joe.jin@oracle.com>

Applied, thank you.
