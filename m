From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/2] rocker: unused parameter and const cleanups
Date: Wed, 13 May 2015 14:52:27 +0900
Message-ID: <1431496349-14833-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35335 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbEMFwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:52:42 -0400
Received: by pabtp1 with SMTP id tp1so39551127pab.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 22:52:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides some minor though verbose cleanup of rocker.

The second patch depends on the first though it could be rebased.

Simon Horman (2):
  rocker: remove unused rocker_port parameter from rocker_port_kfree
  rocker: mark parameters and local variables as const

 drivers/net/ethernet/rocker/rocker.c | 316 ++++++++++++++++++-----------------
 1 file changed, 163 insertions(+), 153 deletions(-)

-- 
2.1.4
