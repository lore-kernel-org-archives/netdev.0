From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2 v2] net: Cache dst in tunnels
Date: Wed, 18 Dec 2013 12:06:25 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312181158260.31084@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:43198 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab3LRUG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 15:06:27 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so37589oah.4
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 12:06:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 2 of caching routing in tunnels.

There are two patches (variants) in the series:
1) One dst cache for each tunnel.
2) Percpu dst cache per tunnel to avoid false sharing
