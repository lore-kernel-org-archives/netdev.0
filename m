From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/17 v2] net: Add rxhash utility hash functions
Date: Tue, 26 Nov 2013 09:22:14 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260913490.21031@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:62203 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757478Ab3KZRWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:22:18 -0500
Received: by mail-oa0-f73.google.com with SMTP id i4so1251583oah.4
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:22:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: Change occurences of 'get' to be 'set' in commit logs.

This patch series introduce skb_set_rxhash and skb_clear_rxhash
which are called to set the rxhash (from network drivers) and
to clear the rxhash. This API should be used instead of updating
fields in the skbuff directly.

Verified that the drivers compiled with the changes (verified
bnx2x is operational).

By my count 15 NIC drivers set the rxhash, but only two of them
mark the hash as L4. It looks like several of those have capability
do determine an L4 hash was done.
