From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v4 0/6] Covscan: Fixes for string termination
Date: Thu, 24 Aug 2017 15:16:48 -0700
Message-ID: <20170824151648.0b6a8ca6@xeon-e3>
References: <20170824095150.5469-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:38871 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753949AbdHXWQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:16:57 -0400
Received: by mail-pg0-f49.google.com with SMTP id b8so4236657pgn.5
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:16:56 -0700 (PDT)
In-Reply-To: <20170824095150.5469-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Aug 2017 11:51:44 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 dealing with code potentially
> leaving string buffers unterminated. This does not include situations
> where it happens for parsed interface names since an overall solution
> was attempted for that and it's state is still unclear due to lack of
> feedback from upstream.
> 
> Changes since v3:
> - Dropped patch 2 since upstream discussion in v3 is not conclusive yet.
> 
> Phil Sutter (6):
>   ipntable: Avoid memory allocation for filter.name
>   lib/fs: Fix format string in find_fs_mount()
>   lib/inet_proto: Review inet_proto_{a2n,n2a}()
>   lnstat_util: Simplify alloc_and_open() a bit
>   tc/m_xt: Fix for potential string buffer overflows
>   lib/ll_map: Choose size of new cache items at run-time
> 
>  ip/ipntable.c      |  6 +++---
>  lib/fs.c           |  2 +-
>  lib/inet_proto.c   | 24 +++++++++++++-----------
>  lib/ll_map.c       |  4 ++--
>  misc/lnstat_util.c |  7 ++-----
>  tc/m_xt.c          |  7 ++++---
>  6 files changed, 25 insertions(+), 25 deletions(-)
> 

Applied.
