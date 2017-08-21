From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: Add the invalid handle check in
 qdisc_class_find
Date: Mon, 21 Aug 2017 10:47:49 -0700 (PDT)
Message-ID: <20170821.104749.419102990180912192.davem@davemloft.net>
References: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jhs@mojatatu.com
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbdHURru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:47:50 -0400
In-Reply-To: <1503041004-105572-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Fri, 18 Aug 2017 15:23:24 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> Add the invalid handle "0" check to avoid unnecessary search, because
> the qdisc uses the skb->priority as the handle value to look up, and
> it is "0" usually.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Jamal, Cong, please review.

If 'id' zero is never hashed into the tables, this change looks
legitimate.
