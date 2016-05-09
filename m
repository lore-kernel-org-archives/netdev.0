From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qede: uninitialized variable in qede_start_xmit()
Date: Sun, 08 May 2016 23:32:08 -0400 (EDT)
Message-ID: <20160508.233208.1239185600962622193.davem@davemloft.net>
References: <20160505132130.GE3038@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160505132130.GE3038@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 May 2016 16:21:30 +0300

> "data_split" was never set to false.  It's just uninitialized.
> 
> Fixes: 2950219d87b0 ('qede: Add basic network device support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
