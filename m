From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] sfc: Add sysfs entry for physical port
Date: Sun, 31 May 2015 17:32:19 -0700 (PDT)
Message-ID: <20150531.173219.1881314735933860028.davem@davemloft.net>
References: <55683895.2090408@solarflare.com>
	<556838E2.3040405@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbbFAAcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 20:32:20 -0400
In-Reply-To: <556838E2.3040405@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 29 May 2015 11:01:06 +0100

> In the case where we have multiple functions (PFs and VFs), this
> sysfs entry is useful to identify the physical port corresponding
> to the function we are interested in.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Please don't invent your own stuff for this, you are not the only driver
in the world that might want to export this kind of information.

Set netdev->dev_port properly and it'll already be exported for you
using portable, standard interfaces, that a user can use with any
device in the world, not just your's.
