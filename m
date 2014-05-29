From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/7] net: Support checksum in UDP tunnels
Date: Wed, 28 May 2014 21:23:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405282110290.32618@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:48102 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbaE2EXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 00:23:19 -0400
Received: by mail-ve0-f201.google.com with SMTP id db11so2103299veb.4
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 21:23:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for using checksums in UDP tunnels. With
this it is possible that two or more checksums may be set within the
same packet and we would like to do that efficiently.

This series also creates some new helper functions to be used by various
tunnel protocol implementations.
