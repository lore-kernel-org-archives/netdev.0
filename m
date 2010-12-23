From: David Miller <davem@davemloft.net>
Subject: Re: [patch] USB: mcs7830: return negative if auto negotiate fails
Date: Thu, 23 Dec 2010 10:22:16 -0800 (PST)
Message-ID: <20101223.102216.260073588.davem@davemloft.net>
References: <20101217132542.GL1639@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753147Ab0LWSVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 13:21:47 -0500
In-Reply-To: <20101217132542.GL1639@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 17 Dec 2010 16:25:43 +0300

> The original code returns 0 on success and 1 on failure.  In fact, at
> this point, "ret" is already either zero or a negative error code so
> we can just return it directly.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Indeed, the USBNET ->bind() method, which this return value propagates
to, expects negative return values on error.

Applied, and queued up for -stable, thanks Dan.
