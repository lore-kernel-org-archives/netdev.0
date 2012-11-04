From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 2/5] usbnet: smsc75xx: apply the introduced
 usbnet_read[write]_cmd_nopm
Date: Sun, 04 Nov 2012 01:58:34 -0400 (EDT)
Message-ID: <20121104.015834.655875426096699012.davem@davemloft.net>
References: <1351992594-12818-1-git-send-email-ming.lei@canonical.com>
	<1351992594-12818-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	steve.glendinning@shawell.net
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab2KDF6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 01:58:36 -0400
In-Reply-To: <1351992594-12818-3-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Sun,  4 Nov 2012 09:29:51 +0800

> This patch applies the introduced usbnet_read_cmd_nopm() and
> usbnet_write_cmd_nopm() in the callback of resume and suspend
> to avoid deadlock if USB runtime PM is considered into
> usbnet_read_cmd() and usbnet_write_cmd().
> 
> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

This gets rejects, you didn't have your net-next tree uptodate
enough.
