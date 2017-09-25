From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] l2tp: fix some races in session deletion
Date: Mon, 25 Sep 2017 14:45:01 -0700 (PDT)
Message-ID: <20170925.144501.1323337645764754009.davem@davemloft.net>
References: <cover.1506086081.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, tparkin@katalix.com,
        sd@queasysnail.net
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932698AbdIYVpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:45:02 -0400
In-Reply-To: <cover.1506086081.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 22 Sep 2017 15:39:22 +0200

> L2TP provides several interfaces for deleting sessions. Using two of
> them concurrently can lead to use-after-free bugs.
> 
> Patch #2 uses a flag to prevent double removal of L2TP sessions.
> Patch #1 fixes a bug found in the way. Fixing this bug is also
> necessary for patch #2 to handle all cases.
> 
> This issue is similar to the tunnel deletion bug being worked on by
> Sabrina: https://patchwork.ozlabs.org/patch/814173/

Series applied and queued up for -stable, thanks.
