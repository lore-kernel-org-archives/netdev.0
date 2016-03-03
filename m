From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: moxa: fix an error code
Date: Thu, 03 Mar 2016 17:17:39 -0500 (EST)
Message-ID: <20160303.171739.1237357288526058790.davem@davemloft.net>
References: <20160302101110.GI5533@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonas.jensen@gmail.com, luis@debethencourt.com, arnd@arndb.de,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160302101110.GI5533@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Mar 2016 13:11:10 +0300

> We accidentally return IS_ERR(priv->base) which is 1 instead of
> PTR_ERR(priv->base) which is the error code.
> 
> Fixes: 6c821bd9edc9 ('net: Add MOXA ART SoCs ethernet driver')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thank you Dan.
