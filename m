From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 0/7] Covscan: Dead code elimination
Date: Mon, 21 Aug 2017 17:13:55 -0700
Message-ID: <20170821171355.6cc4d6a7@xeon-e3>
References: <20170817170931.24089-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34777 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754242AbdHVAOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:14:03 -0400
Received: by mail-pg0-f42.google.com with SMTP id s14so4018279pgs.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:14:02 -0700 (PDT)
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:24 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 which deal with dead code, either
> by removing it or changing context so it is accessed again if that makes
> sense.
> 
> No changes to the actual patches, just splitting into smaller series.
> 
> Phil Sutter (7):
>   devlink: No need for this self-assignment
>   ipntable: No need to check and assign to parms_rta
>   iproute: Fix for missing 'Oifs:' display
>   lib/rt_names: Drop dead code in rtnl_rttable_n2a()
>   ss: Skip useless check in parse_hostcond()
>   ss: Drop useless assignment
>   tc/m_gact: Drop dead code
> 
>  devlink/devlink.c |  2 +-
>  ip/ipntable.c     |  2 --
>  ip/iproute.c      |  8 +++++---
>  lib/rt_names.c    |  4 ----
>  misc/ss.c         |  3 +--
>  tc/m_gact.c       | 14 +++-----------
>  6 files changed, 10 insertions(+), 23 deletions(-)
> 

Sure these look fine. Applied.
