From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] hyperv: NULL dereference on error
Date: Fri, 05 Sep 2014 17:29:42 -0700 (PDT)
Message-ID: <20140905.172942.910314558476835347.davem@davemloft.net>
References: <20140904111123.GD21504@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140904111123.GD21504@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 4 Sep 2014 14:11:23 +0300

> We try to call free_netvsc_device(net_device) when "net_device" is NULL.
> It leads to an Oops.
> 
> Fixes: f90251c8a6d0 ('hyperv: Increase the buffer length for netvsc_channel_cb()')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
