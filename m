From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] nfp: check idx is -ENOSPC before using it is an
 index
Date: Mon, 11 Jul 2016 13:52:18 -0700 (PDT)
Message-ID: <20160711.135218.1535273154348680313.davem@davemloft.net>
References: <1468252460-15117-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	rolf.neugebauer@netronome.com, christophe.ricard@gmail.com,
	robert.dolca@intel.com, oss-drivers@netronome.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbcGKUwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:52:20 -0400
In-Reply-To: <1468252460-15117-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Mon, 11 Jul 2016 16:54:20 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> idx can be returned as -ENOSPC, so we should check for this first
> before using it as an index into nn->vxlan_usecnt[] to avoid an
> out of bounds array offset read.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next.
