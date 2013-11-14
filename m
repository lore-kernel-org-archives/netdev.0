From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cdc_ncm: cleanup a type issue in cdc_ncm_setup()
Date: Thu, 14 Nov 2013 03:10:57 -0500 (EST)
Message-ID: <20131114.031057.1514427325797937478.davem@davemloft.net>
References: <20131113074234.GB25541@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab3KNILE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:11:04 -0500
In-Reply-To: <20131113074234.GB25541@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 13 Nov 2013 10:42:34 +0300

> This is harmless but cdc_ncm_setup() returns negative error codes
> truncated to u8 values.  There is only one caller and treats all
> non-zero returns as errors but doesn't store the the return code.  So
> the code works correctly but it's messy and upsets the static checkers.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
