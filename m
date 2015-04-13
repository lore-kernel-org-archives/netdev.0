From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/4] Allow use of rocker ports without bridging
Date: Mon, 13 Apr 2015 15:47:53 +0900
Message-ID: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35893 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbbDMGsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:48:19 -0400
Received: by pdea3 with SMTP id a3so97206626pde.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:48:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series attempts to allow rocker ports to be used when they
are not attached to a bridge. It attempts to make use of flow entries
in a rocker switch where appropriate and otherwise forwards packets up
to the kernel for processing.

I have lightly tested this series using unicast IPv4 (mainly ARP and ping).

Simon Horman (4):
  rocker: add helper for setting untagged VLAN
  rocker: set untagged VLAN when opening port
  rocker: forward packets to CPU when a port not bridged
  rocker: allow forwarding of IPv4 by unicast routing table

 drivers/net/ethernet/rocker/rocker.c | 138 ++++++++++++++++++++++++++++-------
 1 file changed, 110 insertions(+), 28 deletions(-)

-- 
2.1.4
