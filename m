From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/3] nfp: few code improvements
Date: Wed, 29 Jun 2016 21:55:52 +0100
Message-ID: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38231 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbcF2VEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:04:37 -0400
Received: by mail-wm0-f52.google.com with SMTP id r201so91005742wme.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:04:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Three small patches for net-next.  First and second patches
improve the code quality by spelling things correctly and
removing unused parameters.  Third patch hooks-in standard
kernel implementation of .get_link() in ethtool ops.

Jakub Kicinski (3):
  nfp: correct name of control BAR define
  nfp: remove unused parameter from nfp_net_write_mac_addr()
  nfp: implement ethtool .get_link() callback

 drivers/net/ethernet/netronome/nfp/nfp_net.h         |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  | 13 +++++++------
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c  |  4 ++--
 4 files changed, 11 insertions(+), 9 deletions(-)

-- 
1.9.1
