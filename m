From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v3 net-next 0/2] rocker: unused parameter and const cleanups
Date: Mon, 25 May 2015 14:28:34 +0900
Message-ID: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36539 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbEYF2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 01:28:54 -0400
Received: by paza2 with SMTP id a2so54499486paz.3
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 22:28:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides some minor though verbose cleanup of rocker.

The second patch depends on the first though it could be rebased.

I had previously asked for v2 to be put on hold while some bugs I had found
in the rocker driver were shaken out. That has now happened and the bugs
turned out to be unrelated.  Accordingly I am reposting the series.


* Changes v2 -> v3
  - Rebase and update for new variables and parameters that may be const

* Changes v1 -> v2
  - Found quite a few more variables and parameters to make const

Simon Horman (2):
  rocker: remove unused rocker_port parameter from rocker_port_kfree
  rocker: mark parameters and local variables as const

 drivers/net/ethernet/rocker/rocker.c | 469 ++++++++++++++++++-----------------
 1 file changed, 240 insertions(+), 229 deletions(-)

-- 
2.1.4
