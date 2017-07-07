From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: flower: add missing clean up call to avoid
 memory leaks
Date: Fri, 07 Jul 2017 09:17:55 +0100 (WEST)
Message-ID: <20170707.091755.2002801864691908731.davem@davemloft.net>
References: <20170707002905.31111-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbdGGISI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 04:18:08 -0400
In-Reply-To: <20170707002905.31111-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu,  6 Jul 2017 17:29:05 -0700

> nfp_flower_metadata_cleanup() is defined but never invoked,
> not calling it will cause us to leak mask and statistics
> queue memory on the host.
> 
> Fixes: 43f84b72c50d ("nfp: add metadata to each flow offload")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
