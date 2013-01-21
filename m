From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: pegasus: set wakeup enable in set_wol
Date: Sun, 20 Jan 2013 23:12:21 -0500 (EST)
Message-ID: <20130120.231221.1957070409053121002.davem@davemloft.net>
References: <1358595121-14373-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	sarah.a.sharp@linux.intel.com, petkan@users.sourceforge.net
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3AUEMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 23:12:22 -0500
In-Reply-To: <1358595121-14373-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Sat, 19 Jan 2013 19:32:01 +0800

> This patch calls device_set_wakeup_enable() inside set_wol
> callback, so that turning on WOL from user mode utility
> can make the 'wakeup' of pegasus device to be enabled, then
> remote wakeup may be enabled before putting into sleep.
> 
> Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>
> Cc: Petko Manolov <petkan@users.sourceforge.net>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

Applied to net-next, thanks Ming.
