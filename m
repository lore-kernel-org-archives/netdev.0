From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] net: Do not allow negative values for busy_read and
 busy_poll sysctl interfaces
Date: Fri, 24 Mar 2017 12:43:45 -0700
Message-ID: <1490384625.9687.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170324163630.14764.75429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36277 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbdCXTns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:43:48 -0400
Received: by mail-pg0-f66.google.com with SMTP id 81so2273pgh.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 12:43:47 -0700 (PDT)
In-Reply-To: <20170324163630.14764.75429.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-24 at 09:38 -0700, Alexander Duyck wrote:
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
> ---


Acked-by: Eric Dumazet <edumazet@google.com>
