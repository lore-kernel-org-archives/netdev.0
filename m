From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/17] net: Add rxhash utility hash functions
Date: Mon, 25 Nov 2013 21:45:57 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252140410.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:42576 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3KZFp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:45:59 -0500
Received: by mail-ob0-f202.google.com with SMTP id gq1so1115475obb.1
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:45:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series introduce skb_set_rxhash and skb_clear_rxhash
which are called to set the rxhash (from network drivers) and
to clear the rxhash. This API should be used instead of updating
fields in the skbuff directly.

Verified that the drivers compiled with the changes (verified
bnx2x is operational).

By my count 15 NIC drivers set the rxhash, but only two of them
mark the hash as L4. It looks like several of those have capability
do determine an L4 hash was done.
