From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] net: Do not allow negative values for busy_read
 and busy_poll sysctl interfaces
Date: Fri, 24 Mar 2017 15:02:38 -0700 (PDT)
Message-ID: <20170324.150238.1364516032866728084.davem@davemloft.net>
References: <20170324163630.14764.75429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752618AbdCXWDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:03:07 -0400
In-Reply-To: <20170324163630.14764.75429.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 24 Mar 2017 09:38:03 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change basically codifies what I think was already the limitations on
> the busy_poll and busy_read sysctl interfaces.  We weren't checking the
> lower bounds and as such could input negative values. The behavior when
> that was used was dependent on the architecture. In order to prevent any
> issues with that I am just disabling support for values less than 0 since
> this way we don't have to worry about any odd behaviors.
> 
> By limiting the sysctl values this way it also makes it consistent with how
> we handle the SO_BUSY_POLL socket option since the value appears to be
> reported as a signed integer value and negative values are rejected.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks.
