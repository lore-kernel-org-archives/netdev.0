From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v4] net: fec: fix compile with CONFIG_M5272
Date: Tue, 06 Dec 2016 11:41:18 -0500 (EST)
Message-ID: <20161206.114118.1767470949826868325.davem@davemloft.net>
References: <1481005613-5147-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        andrew@lunn.ch, eric@nelint.com, tremyfr@gmail.com,
        johannes@sipsolutions.net, netdev@vger.kernel.org,
        cphealy@gmail.com, fabio.estevam@nxp.com,
        linux-kernel@vger.kernel.org
To: nikita.yoush@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752258AbcLFQlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 11:41:20 -0500
In-Reply-To: <1481005613-5147-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Tue,  6 Dec 2016 09:26:53 +0300

> Commit 80cca775cdc4 ("net: fec: cache statistics while device is down")
> introduced unconditional statistics-related actions.
> 
> However, when driver is compiled with CONFIG_M5272, staticsics-related
> definitions do not exist, which results into build errors.
> 
> Fix that by adding explicit handling of !defined(CONFIG_M5272) case.
> 
> Fixes: 80cca775cdc4 ("net: fec: cache statistics while device is down")
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>

Applied.
