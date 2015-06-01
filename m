From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 01/14] sfc: Add code to export port_num in
 netdev->dev_port
Date: Mon, 01 Jun 2015 12:01:00 -0700 (PDT)
Message-ID: <20150601.120100.1499695282057656297.davem@davemloft.net>
References: <556C5704.4060901@solarflare.com>
	<556C575C.2040403@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbFATBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:01:03 -0400
In-Reply-To: <556C575C.2040403@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Mon, 1 Jun 2015 14:00:12 +0100

> In the case where we have multiple functions (PFs and VFs), this
> sysfs entry is useful to identify the physical port corresponding
> to the function we are interested in.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

This is a low effort change.

You retained all of the error handling changes that were only necessary when
you added the new sysfs file, but are completely unnecessary if you're
just reporting it via netdev->dev_port.

This is extremely disappointing, because you expect me to put a good effort
into reviewing your changes yet you aren't putting that level of effort into
the submission itself.
