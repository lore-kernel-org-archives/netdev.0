From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net-next 0/2] rocker: unused parameter and const cleanups
Date: Thu, 14 May 2015 12:42:54 +0900
Message-ID: <1431574976-18214-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34535 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934163AbbENDnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:43:10 -0400
Received: by pdbqa5 with SMTP id qa5so71439785pdb.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 20:43:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides some minor though verbose cleanup of rocker.

The second patch depends on the first though it could be rebased.

* Changes v1 -> v2
  - Found quite a few more variables and parameters to make const

Simon Horman (2):
  rocker: remove unused rocker_port parameter from rocker_port_kfree
  rocker: mark parameters and local variables as const

 drivers/net/ethernet/rocker/rocker.c | 454 ++++++++++++++++++-----------------
 1 file changed, 232 insertions(+), 222 deletions(-)

-- 
2.1.4
