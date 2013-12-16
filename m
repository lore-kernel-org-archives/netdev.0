From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/4 v3] net: Add rxhash utility hash functions
Date: Sun, 15 Dec 2013 22:11:50 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312152204580.20359@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:42020 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab3LPGLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:11:52 -0500
Received: by mail-ob0-f201.google.com with SMTP id wp4so870004obc.2
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:11:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:

There's really nothing specific about rxhash that constrains
it to be a value just for these receive path. Drop the 'rx'
part in utility functions, including skb_get_rxhash. In subsequent
patches, we can change the rxhash and l4_rxhash names also, as
well as abstracting out the interface to the hash.

Added comments about hash types per feedback.

In this version I'm omitting the changes to drivers to make the
patch set manageable. Will add those changes in followup pathes.

-----
This patch series introduce skb_set_rxhash and skb_clear_rxhash
which are called to set the rxhash (from network drivers) and
to clear the rxhash. This API should be used instead of updating
fields in the skbuff directly.
