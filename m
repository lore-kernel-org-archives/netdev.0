From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: cleanup after bind() in probe()
Date: Mon, 07 Mar 2016 11:41:25 -0500 (EST)
Message-ID: <20160307.114125.198056880799710267.davem@davemloft.net>
References: <1457346670-24059-1-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, bjorn@mork.no
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbcCGQl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:41:29 -0500
In-Reply-To: <1457346670-24059-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Mon,  7 Mar 2016 11:31:10 +0100

> In case bind() works, but a later error forces bailing
> in probe() in error cases work and a timer may be scheduled.
> They must be killed. This fixes an error case related to
> the double free reported in
> http://www.spinics.net/lists/netdev/msg367669.html
> and needs to go on top of Linus' fix to cdc-ncm.
> 
> Signed-off-by: Oliver Neukum <ONeukum@suse.com>

Applied, thanks Oliver.

How far back does this bug exist?  I'm trying to figure out what
-stable branchs to send it to.

Thanks.
