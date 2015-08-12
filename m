From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cosa: missing error code on failure in probe()
Date: Wed, 12 Aug 2015 16:53:36 -0700 (PDT)
Message-ID: <20150812.165336.2268773856388173453.davem@davemloft.net>
References: <20150812210800.GB8068@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbHLXxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:53:37 -0400
In-Reply-To: <20150812210800.GB8068@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 13 Aug 2015 00:08:01 +0300

> If register_hdlc_device() fails, the current code returns 0 but we
> should return an error code instead.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
