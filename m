From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Mon, 11 Aug 2008 10:01:26 +0000
Message-ID: <20080811100126.GA6401@ff.dom.local>
References: <20080810190458.GA7279@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:40645 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbYHKKBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 06:01:35 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1723085fkq.5
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 03:01:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080810190458.GA7279@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-08-2008 21:04, Jarek Poplawski wrote:
...
> Hmm.. Actually, it's completely unreasonable. Let's forget this.

But accidentally it might even sometimes work here...

Currently, the most suspicious place to me seems to be
__netif_schedule(). Is it legal to store RCU protected pointers out of
rcu_read_lock() sections?

Jarek P.
