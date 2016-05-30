From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ptp: oops in ptp_ioctl()
Date: Sun, 29 May 2016 22:32:58 -0700 (PDT)
Message-ID: <20160529.223258.480260903888395056.davem@davemloft.net>
References: <20160526064622.GA6776@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, falakreyaz@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160526064622.GA6776@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 26 May 2016 09:46:22 +0300

> If we pass ERR_PTR(-EFAULT) to kfree() then it's going to oops.
> 
> Fixes: 2ece068e1b1d ('ptp: use memdup_user().')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
