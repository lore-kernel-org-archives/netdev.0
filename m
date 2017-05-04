From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4, ipv6: ensure raw socket message is big enough to
 hold an IP header
Date: Thu, 04 May 2017 11:07:45 -0400 (EDT)
Message-ID: <20170504.110745.1166031278249644101.davem@davemloft.net>
References: <20170503150658.44421-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754223AbdEDPHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:07:47 -0400
In-Reply-To: <20170503150658.44421-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Potapenko <glider@google.com>
Date: Wed,  3 May 2017 17:06:58 +0200

> raw_send_hdrinc() and rawv6_send_hdrinc() expect that the buffer copied
> from the userspace contains the IPv4/IPv6 header, so if too few bytes are
> copied, parts of the header may remain uninitialized.
> 
> This bug has been detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Applied and queued up for -stable, thanks.
