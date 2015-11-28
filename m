From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/5] warning-annoyance induced code-review
Date: Sat, 28 Nov 2015 01:00:00 +0100
Message-ID: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38375 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbK1AAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 19:00:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The primary goal was to get rid of the -Wunused-result warnings emitted
during compiling. While adding the necessary checks, I found a few
functions which could benefit from a bigger review (patches 1, 2 and 3).
Patch 4 then adds the remaining missing checks, and patch 5 simplifies
fgets() usage at a few spots.

Note that the last patch is my first Coccinelle-generated change, which
makes me especially proud. Many thanks again to Julia Lawall for her kind
support via IRC at this point!

Phil Sutter (5):
  lnstat: review lnstat_update()
  ss: reduce max indentation level in init_service_resolver()
  ss: review is_ephemeral()
  get rid of remaining -Wunused-result warnings
  get rid of unnecessary fgets() buffer size limitation

 misc/arpd.c        |   2 +-
 misc/ifstat.c      |   6 ++-
 misc/lnstat_util.c |  21 +++++------
 misc/nstat.c       |   6 ++-
 misc/ss.c          | 107 ++++++++++++++++++++++++++++-------------------------
 5 files changed, 74 insertions(+), 68 deletions(-)

-- 
2.5.0
