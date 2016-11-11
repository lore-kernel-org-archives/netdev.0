From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 00/18] ss: Minor code review
Date: Fri, 11 Nov 2016 14:09:56 +0100
Message-ID: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33023 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756485AbcKKNLK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of misc changes to ss code which happened as fall-out
when working on a unified output formatter (still unfinished).

Phil Sutter (18):
  ss: Mark fall through in arg parsing switch()
  ss: Drop empty lines in UDP output
  ss: Add missing tab when printing UNIX details
  ss: Use sockstat->type in all socket types
  ss: introduce proc_ctx_print()
  ss: Drop list traversal from unix_stats_print()
  ss: Eliminate unix_use_proc()
  ss: Turn generic_proc_open() wrappers into macros
  ss: Make tmr_name local to tcp_timer_print()
  ss: Make user_ent_hash_build_init local to user_ent_hash_build()
  ss: Make some variables function-local
  ss: Make slabstat_ids local to get_slabstat()
  ss: Get rid of useless goto in handle_follow_request()
  ss: Get rid of single-fielded struct snmpstat
  ss: Make unix_state_map local to unix_show()
  ss: Make sstate_name local to sock_state_print()
  ss: Make sstate_namel local to scan_state()
  ss: unix_show: No need to initialize members of calloc'ed structs

 misc/ss.c | 524 ++++++++++++++++++++++++++------------------------------------
 1 file changed, 220 insertions(+), 304 deletions(-)

-- 
2.10.0
