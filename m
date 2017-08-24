From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 0/6] Covscan: Misc fixes
Date: Thu, 24 Aug 2017 15:30:09 -0700
Message-ID: <20170824153009.49ecd130@xeon-e3>
References: <20170824094131.2963-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34126 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753814AbdHXWaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:30:11 -0400
Received: by mail-pg0-f48.google.com with SMTP id a7so3945836pgn.1
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:30:11 -0700 (PDT)
In-Reply-To: <20170824094131.2963-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Aug 2017 11:41:25 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series collects patches from v1 addressing miscellaneous issues
> detected by covscan.
> 
> Changes since v2:
> - Dropped patch 1 since v2 discussion is still inconclusive.
> - Replaced patch 2 by a more appropriate one given feedback from v2.
> 
> Phil Sutter (6):
>   ss: Make struct tcpstat fields 'timer' and 'timeout' unsigned
>   ss: Make sure scanned index value to unix_state_map is sane
>   netem/maketable: Check return value of fscanf()
>   lib/bpf: Check return value of write()
>   lib/fs: Fix and simplify make_path()
>   lib/libnetlink: Don't pass NULL parameter to memcpy()
> 
>  lib/bpf.c         |  3 ++-
>  lib/fs.c          | 20 +++++---------------
>  lib/libnetlink.c  |  6 ++++--
>  misc/ss.c         | 11 +++++------
>  netem/maketable.c |  4 ++--
>  5 files changed, 18 insertions(+), 26 deletions(-)
> 

Applied this group
