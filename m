From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 0/7] net: Support checksum in UDP tunnels
Date: Sun, 1 Jun 2014 21:00:38 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406012046040.20298@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:45133 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaFBEAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:00:39 -0400
Received: by mail-oa0-f74.google.com with SMTP id m1so871907oag.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 21:00:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for using checksums in UDP tunnels. With
this it is possible that two or more checksums may be set within the
same packet and we would like to do that efficiently.

This series also creates some new helper functions to be used by various
tunnel protocol implementations.

v2: Fixed indentation in tcp_v6_send_check arguments.
