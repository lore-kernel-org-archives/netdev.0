From: David Miller <davem@davemloft.net>
Subject: Re: possible unannotated irqs-off
Date: Tue, 14 Feb 2017 14:46:48 -0500 (EST)
Message-ID: <20170214.144648.771654199689384203.davem@davemloft.net>
References: <20170214172858.07d4393a@darkbook.lan.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: rnsanchez@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdBNTqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:46:54 -0500
In-Reply-To: <20170214172858.07d4393a@darkbook.lan.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
Date: Tue, 14 Feb 2017 17:28:58 -0200

> [   93.509167]  ? jtcp_rcv_established+0x8e/0x2d0
> [   93.509173]  jtcp_rcv_established+0x8e/0x2d0

What are you using this TCP probe for?  That's where the locking
problem is happening.
