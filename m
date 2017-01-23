From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 00/17] gtp: fixes and support multiple VRF's per GTP socket
Date: Mon, 23 Jan 2017 12:56:49 +0100
Message-ID: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:33797 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751072AbdAWMGz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current linking of GTP network devices and GTP enabled sockets means that
we can not have multiple VRF's per GTP socket. This series seperates the
sockets from network device, makes sockets attached to GTP network device
optional and adds a API function to enable GTP encapsulation on socket
without having to create a new GTP device.

It is still possible to use the old API. The network device attached socket is
then used when no socket is specified on PDP context creation.

During that work some smaller problems where found and fixes for them are
included.

Regards
Andreas
