From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hsr: off by one sanity check in hsr_register_frame_in()
Date: Mon, 03 Mar 2014 15:30:15 -0500 (EST)
Message-ID: <20140303.153015.1785335562028272449.davem@davemloft.net>
References: <20140228231857.GD22115@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140228231857.GD22115@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 1 Mar 2014 02:18:57 +0300

> This is a sanity check and we never pass invalid values so this patch
> doesn't change anything.  However the node->time_in[] array has
> HSR_MAX_SLAVE (2) elements and not HSR_MAX_DEV (3).
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
