From: sfeldma@gmail.com
Subject: [PATCH net-next 0/3] rocker cleanups
Date: Wed, 25 Feb 2015 20:15:35 -0800
Message-ID: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33770 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbbBZEPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:15:13 -0500
Received: by pabkx10 with SMTP id kx10so10775954pab.0
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:15:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Pushing out some rocker cleanups I've had in my queue for a while.  Nothing
major, just some sync-up with changes that already went into device code
(hard-coding desc err return values and lport renaming).  Also fixup
port fowarding transitions prompted by some DSA discussions about how to
restore port state when port leaves bridge.

Scott Feldman (3):
  rocker: fix non-portable err return codes
  rocker: rename lport to pport
  rocker: put port in FORWADING state after leaving bridge

 drivers/net/ethernet/rocker/rocker.c |  255 ++++++++++++++++++++--------------
 drivers/net/ethernet/rocker/rocker.h |   29 ++--
 2 files changed, 170 insertions(+), 114 deletions(-)

-- 
1.7.10.4
