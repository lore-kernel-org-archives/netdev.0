From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] pch_gbe: fix if condition in set_settings()
Date: Sat, 16 Oct 2010 11:55:31 -0700 (PDT)
Message-ID: <20101016.115531.183030637.davem@davemloft.net>
References: <20101013093619.GC6060@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, masa-korg@dsn.okisemi.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:08 -0400
In-Reply-To: <20101013093619.GC6060@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 13 Oct 2010 11:36:19 +0200

> There were no curly braces in this if condition so it always enabled full
> duplex.
> 
> And ecmd->speed is an unsigned short so it is never equal to -1.  The
> effect is that mii_ethtool_sset() fails with -EINVAL and an error is
> printed to dmesg.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
