From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/4] net: rename skb->rxhash
Date: Thu, 20 Mar 2014 17:09:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1403201659430.6983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:40205 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965935AbaCUAJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:09:02 -0400
Received: by mail-qa0-f73.google.com with SMTP id f11so203579qae.4
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 17:09:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set finishes changing skb->rxhash to skb->hash. We
needed to wait until all the drivers were updated to use
skb_set_hash(). Also, use skb_get_hash() in transmit path
for TX hash and XPS.
