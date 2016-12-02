From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 00/18] ss: Minor code review
Date: Fri, 2 Dec 2016 14:09:47 -0800
Message-ID: <20161202140947.11531de5@xeon-e3>
References: <20161202104002.17310-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34876 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753582AbcLBWJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:09:51 -0500
Received: by mail-pf0-f172.google.com with SMTP id i88so54432609pfk.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:09:51 -0800 (PST)
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Dec 2016 11:39:44 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This is a series of misc changes to ss code which happened as fall-out
> when working on a unified output formatter (still unfinished).
> 
> Changes since v1:
> - Rebased onto current upstream, resolved conflicts in patch 4 generated
>   by previously added SCTP socket support.
> 
> Phil Sutter (18):
>   ss: Mark fall through in arg parsing switch()
>   ss: Drop empty lines in UDP output
>   ss: Add missing tab when printing UNIX details
>   ss: Use sockstat->type in all socket types
>   ss: introduce proc_ctx_print()
>   ss: Drop list traversal from unix_stats_print()
>   ss: Eliminate unix_use_proc()
>   ss: Turn generic_proc_open() wrappers into macros
>   ss: Make tmr_name local to tcp_timer_print()
>   ss: Make user_ent_hash_build_init local to user_ent_hash_build()
>   ss: Make some variables function-local
>   ss: Make slabstat_ids local to get_slabstat()
>   ss: Get rid of useless goto in handle_follow_request()
>   ss: Get rid of single-fielded struct snmpstat
>   ss: Make unix_state_map local to unix_show()
>   ss: Make sstate_name local to sock_state_print()
>   ss: Make sstate_namel local to scan_state()
>   ss: unix_show: No need to initialize members of calloc'ed structs
> 
>  misc/ss.c | 532 ++++++++++++++++++++++++++------------------------------------
>  1 file changed, 224 insertions(+), 308 deletions(-)
> 

Applied, thanks
