From: David Miller <davem@davemloft.net>
Subject: Re: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Tue, 17 Jan 2017 12:58:44 -0500 (EST)
Message-ID: <20170117.125844.253301507252169868.davem@davemloft.net>
References: <1484674356-22363-1-git-send-email-roman@advem.lv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leroi.lists@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdAQR6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:58:51 -0500
In-Reply-To: <1484674356-22363-1-git-send-email-roman@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin <leroi.lists@gmail.com>
Date: Tue, 17 Jan 2017 19:32:36 +0200

> Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
> This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)

Those numbers don't mean much without full context.

What kind of system, what kind of traffic, and over what kind of link?
