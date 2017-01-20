From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 11:32:09 -0500 (EST)
Message-ID: <20170120.113209.1764653226397979876.davem@davemloft.net>
References: <20170120134542.21104-1-colin.king@canonical.com>
        <20170120135845.GT3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752663AbdATQle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:41:34 -0500
In-Reply-To: <20170120135845.GT3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 20 Jan 2017 11:58:45 -0200

> Not sure I can add the Fixes tag for you here, but:
> Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

FWIW, patchwork doesn't notice updated Fixes: tags like this but I
try to do so myself and the effort is definitely appreciated.

We need a V3 of this change anyways, see the build failure I reported
for V2, so Colin can add the Fixes: tag there explicitly.
