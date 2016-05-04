From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet: smsc95xx: silence an uninitialized variable
 warning
Date: Wed, 04 May 2016 17:00:01 -0400 (EDT)
Message-ID: <20160504.170001.1649317898691832917.davem@davemloft.net>
References: <20160504062201.GF22064@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbcEDVAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 17:00:03 -0400
In-Reply-To: <20160504062201.GF22064@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 May 2016 09:22:01 +0300

> If the call to fn() fails then "buf" is uninitialized.  Just return the
> error code in that case.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.

Please, in the future, use a consistent subsystem prefixing scheme.  In these
two patches you used "x/y:"" and "x: y:"

Thanks.
