From: Tom Herbert <therbert@google.com>
Subject: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 12:25:48 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:42656 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144Ab3KTUco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:32:44 -0500
Received: by mail-ie0-f201.google.com with SMTP id at1so533647iec.4
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:32:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes some subtle bugs in tun use of skb->rxhash, all
rxhash hash not be cleared appropraitely, and adds support for tun flows
to work with RFS.


Testing, in particular with tun, hasn't been completed yet.
