From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] typhoon: memory corruption in
 typhoon_get_drvinfo()
Date: Mon, 20 Dec 2010 10:43:21 -0800 (PST)
Message-ID: <20101220.104321.183048943.davem@davemloft.net>
References: <20101220130018.GX1936@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757391Ab0LTSmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:42:52 -0500
In-Reply-To: <20101220130018.GX1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 20 Dec 2010 16:00:18 +0300

> info->version only has space for 32 characters but my UTS_RELEASE is
> "2.6.37-rc6-next-20101217-05817-ge935fc8-dirty" so it doesn't fit.
> This is supposed to be the version of the driver, not the kernel
> version.  This driver doesn't have a version so lets just leave it
> blank.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
