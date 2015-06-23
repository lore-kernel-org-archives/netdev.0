From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: fdb filter_dev is always NULL for
 self (device), so remove check
Date: Tue, 23 Jun 2015 00:58:55 -0700 (PDT)
Message-ID: <20150623.005855.372472229421613354.davem@davemloft.net>
References: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	sridhar.samudrala@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbFWHrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 03:47:08 -0400
In-Reply-To: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 17 Jun 2015 16:08:31 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Remove the filter_dev check when dumping fdb entries, otherwise dump
> returns empty list.  filter_dev is always passed as NULL when dumping fdbs
> on SELF.  We want the fdbs installed on the device to be listed in the
> dump.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Fixes: 45d4122c ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops")

Applied, thanks.
