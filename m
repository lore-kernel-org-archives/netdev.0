From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunder: Fix crash upon shutdown after failed
 probe
Date: Sun, 15 Nov 2015 18:30:37 -0500 (EST)
Message-ID: <20151115.183037.1090427973434503108.davem@davemloft.net>
References: <1447329318-7840-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbbKOXak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 18:30:40 -0500
In-Reply-To: <1447329318-7840-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Thu, 12 Nov 2015 14:55:18 +0300

> If device probe fails, driver remains bound to the PCI device. However,
> driver data has been reset to NULL. This causes crash upon dereferencing
> it in nicvf_remove()
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied, thanks.
