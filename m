From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] minor update to bridge.8
Date: Wed, 18 Nov 2015 12:46:41 +0100
Message-ID: <1447847203-7462-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38956 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224AbbKRLrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 06:47:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was originally some leftover in RHEL patches, as well. Though the
question whether 'fdb replace' should be documented or not was not
exactly trivial:

- In August 2012, 'fdb change' and 'fdb replace' commands were removed
  (commit 57b9785).
- In September 2012, bridge.8 was adjusted accordingly (commit d611682).
- In July 2013 though, 'fdb replace' was added again (commit 45a82e5).

The latter maybe should have been a revert, as it misses to add 'fdb
change' as well. Anyway, this series fixes bridge.8 again and
additionally reviews formatting.


Phil Sutter (2):
  bridge.8: document fdb replace command
  bridge.8: minor formatting cleanup

 man/man8/bridge.8 | 57 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 25 deletions(-)

-- 
2.5.0
