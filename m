From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 2/2] kproxy: Kernel proxy
Date: Mon, 03 Jul 2017 06:01:19 -0700 (PDT)
Message-ID: <20170703.060119.365175445188989019.davem@davemloft.net>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
        <1498760825-8516-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752113AbdGCNB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 09:01:26 -0400
In-Reply-To: <1498760825-8516-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 29 Jun 2017 11:27:05 -0700

> A proc file (/prox/net/kproxy) is created to list all the running
> kernel proxies and relevant statistics for them.

proc is deprecated for dumping information like this, please use
sock diag instead.
