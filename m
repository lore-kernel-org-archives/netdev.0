From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: driver: ethernet: add sysfs interface for ti
 cpsw
Date: Tue, 03 Jul 2012 16:16:23 -0700 (PDT)
Message-ID: <20120703.161623.1843927245895613219.davem@davemloft.net>
References: <1341345086-25093-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cyril@ti.com, mugunthanvnm@ti.com, netdev@vger.kernel.org
To: s-paulraj@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab2GCXQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 19:16:24 -0400
In-Reply-To: <1341345086-25093-1-git-send-email-s-paulraj@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <s-paulraj@ti.com>
Date: Tue, 3 Jul 2012 15:51:26 -0400

> From: Sandeep Paulraj <s-paulraj@ti.com>
> 
> This patch adds sysfs entries for address lookup engine entries and
> control for the ALE(address lookup engine) found in TI SOC's.
> 
> 
> Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>

You may not create private, driver specific, unique interfaces to
configure your hardware.

You must use existing facilities such as ethtool to add such things.
If the existing facilities are insufficient, you must extend them to
meet your (and potentially other's) needs.
