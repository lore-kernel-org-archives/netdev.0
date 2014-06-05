From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 0/7] net: Support checksum in UDP
Date: Wed, 4 Jun 2014 17:19:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406041705230.14524@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:46992 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208AbaFEATo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:19:44 -0400
Received: by mail-vc0-f201.google.com with SMTP id hq11so75440vcb.0
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 17:19:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for using checksums in UDP tunnels. With
this it is possible that two or more checksums may be set within the
same packet and we would like to do that efficiently.

This series also creates some new helper functions to be used by various
tunnel protocol implementations.

v2: Fixed indentation in tcp_v6_send_check arguments.
v3: Move udp_set_csum and udp6_set_csum to be not inlined
    Also have this functions call with a nocheck boolean argument
    instead of passing a sock structure.
