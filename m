From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] net: mvneta: use per_cpu stats to fix an SMP lock up
Date: Sun, 12 Jan 2014 16:48:06 -0800
Message-ID: <1389574086.31367.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-3-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:59785 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaAMAsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 19:48:07 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so6628649pbc.12
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 16:48:07 -0800 (PST)
In-Reply-To: <1389519069-1619-3-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:

> This patch implements this. It merges both rx_stats and tx_stats into
> a single "stats" member with a single syncp. Both mvneta_rx() and
> mvneta_rx() now only update the a single CPU's counters.


Reviewed-by: Eric Dumazet <edumazet@google.com>
