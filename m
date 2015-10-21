From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: mv643xx_eth: TSO TX data corruption fixes
Date: Wed, 21 Oct 2015 07:38:22 -0700 (PDT)
Message-ID: <20151021.073822.1887336681948015638.davem@davemloft.net>
References: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org
To: philipp@familie-kirchhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbbJUOV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:21:58 -0400
In-Reply-To: <1445176964-22760-1-git-send-email-philipp@familie-kirchhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Kirchhofer <philipp@familie-kirchhofer.de>
Date: Sun, 18 Oct 2015 16:02:42 +0200

> as previously discussed [1] the mv643xx_eth driver has some
> issues with data corruption when using TCP segmentation offload (TSO).
> 
> The following patch set improves this situation by fixing two data
> corruption bugs in the TSO TX path.
> 
> Before applying the patches repeatedly accessing large files located on
> a SMB share on my NSA325 NAS with TSO enabled resulted in different
> hash sums, which confirmed that data corruption is happening during
> file transfer. After applying the patches the hash sums were the same.
> 
> As this is my first patch submission please feel free to point out any
> issues with the patch set.
> 
> [1] http://thread.gmane.org/gmane.linux.network/336530

Series applied, thanks.
