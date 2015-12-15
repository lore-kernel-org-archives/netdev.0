From: David Miller <davem@davemloft.net>
Subject: Re: [patch -mainline] sfc: fix a timeout loop
Date: Tue, 15 Dec 2015 12:52:32 -0500 (EST)
Message-ID: <20151215.125232.40302839035820823.davem@davemloft.net>
References: <20151215110608.GA10007@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, sshah@solarflare.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151215110608.GA10007@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 14:06:08 +0300

> We test for if "tries" is zero at the end but "tries--" is a post-op so
> it will end with "tries" set to -1.  I have changed it to a pre-op
> instead.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
