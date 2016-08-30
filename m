From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 0/3] macsec: fix input of 'sci' and 'port'
Date: Tue, 30 Aug 2016 13:23:11 +0200
Message-ID: <cover.1472552276.git.dcaratti@redhat.com>
Cc: stephen@networkplumber.org, sd@queasysnail.net, phil@nwl.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757682AbcH3LXw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:23:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides an endianness fix for 'sci' parameter. Moreover, it
allows entering 'port' in hexadecimal format. Finally, related lines in
usage() functions and man pages have been fixed (including missing
documentation of 'address' and  missing 'macsec' item in OBJECT list).

Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Davide Caratti (3):
  macsec: fix input of 'port', improve documentation of 'address'
  man: ip.8: add missing 'macsec' item to OBJECT list
  macsec: fix byte ordering on input/display of 'sci'

 ip/ipmacsec.c         | 14 +++++++-------
 man/man8/ip-link.8.in | 18 ++++++++++++++----
 man/man8/ip-macsec.8  | 12 +++++++++---
 man/man8/ip.8         |  3 ++-
 4 files changed, 32 insertions(+), 15 deletions(-)

-- 
2.5.5
