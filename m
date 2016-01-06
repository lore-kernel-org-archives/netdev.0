From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] fsl/fman: fix the pause_time test
Date: Wed, 06 Jan 2016 15:28:35 -0500 (EST)
Message-ID: <20160106.152835.1032541049238097795.davem@davemloft.net>
References: <20160106095809.GC23185@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igal.liberman@freescale.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbcAFU2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:28:37 -0500
In-Reply-To: <20160106095809.GC23185@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 6 Jan 2016 12:58:09 +0300

> pause_time is unsigned so it can't be less than zero.  The bug means
> that we allow invalid pause-times.
> 
> Fixes: 57ba4c9b56d8 ('fsl/fman: Add FMan MAC support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
