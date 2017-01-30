From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 0/6] gtp: misc improvements
Date: Mon, 30 Jan 2017 17:31:54 +0100
Message-ID: <20170130163200.17070-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:58646 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750834AbdA3QmK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:42:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

This series lays the groundwork for removing the socket references from
the GTP netdevice by removing duplicate code and simplifying the logic on
some code paths.

It slighly changes the GTP genl API by making the socket parameters optional
(though one of them is still required).

The removal of the socket references will break the 1:1 releation between
GTP netdevice and GTP socket that prevents us to support multiple VRFs with
overlaping IP addresse spaces attached to the same GTP socket (needed for
multi APN support).

Regards
Andreas
