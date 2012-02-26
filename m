From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Sun, 26 Feb 2012 14:16:49 -0500 (EST)
Message-ID: <20120226.141649.1425736441415883291.davem@davemloft.net>
References: <1330079992-13368-1-git-send-email-mugunthanvnm@ti.com>
	<1330079992-13368-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab2BZTQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 14:16:52 -0500
In-Reply-To: <1330079992-13368-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 24 Feb 2012 16:09:52 +0530

> +struct cpsw_hw_stats {

Nothing in the driver actually accesses the HW statistics.

Remove this until it's actually going to be used.
