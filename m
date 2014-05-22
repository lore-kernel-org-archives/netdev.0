From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: cdc_ncm: fix typo in test for supported formats
Date: Thu, 22 May 2014 15:53:31 -0400 (EDT)
Message-ID: <20140522.155331.410747192737674451.davem@davemloft.net>
References: <20140522075229.GA4346@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, bjorn@mork.no, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140522075229.GA4346@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 22 May 2014 10:52:29 +0300

> There is a typo here where we test for USB_CDC_NCM_NTH32_SIGN instead
> of USB_CDC_NCM_NTB32_SUPPORTED.  The test probably still works as
> written because 0x686D636E has (1 << 1) set and doesn't have (1 << 0)
> set.
> 
> Fixes: f8afb73da375 ('net: cdc_ncm: factor out one-time device initialization')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
