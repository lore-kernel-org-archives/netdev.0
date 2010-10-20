From: Stephen Hemminger <shemminger@vyatta.com>
Subject: dead code in networking core
Date: Wed, 20 Oct 2010 08:52:29 -0700
Message-ID: <20101020085229.4f908bcd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60937 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129Ab0JTPwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 11:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following API's are exported but unused in current code:
  net/core/dev_addr_lists.o
    __hw_addr_del_multiple
    dev_addr_add_multiple
    dev_addr_del_multiple

  net/core/timestamping.o
    skb_clone_tx_timestamp
    skb_complete_tx_timestamp

Any plans to use these soon?
