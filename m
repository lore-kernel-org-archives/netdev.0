From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v3] net: fec: fix compile with CONFIG_M5272
Date: Mon, 05 Dec 2016 19:56:27 -0500 (EST)
Message-ID: <20161205.195627.1278331886871096866.davem@davemloft.net>
References: <1480959661-29834-1-git-send-email-nikita.yoush@cogentembedded.com>
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
Received: from shards.monkeyblade.net ([184.105.139.130]:58654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbcLFA4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 19:56:30 -0500
In-Reply-To: <1480959661-29834-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon,  5 Dec 2016 20:41:01 +0300

> Commit 4dfb80d18d05 ("net: fec: cache statistics while device is down")
> introduced unconditional statistics-related actions.

I do not see this commit in any of my trees:

[davem@localhost net-next]$ git describe 4dfb80d18d05
fatal: Not a valid object name 4dfb80d18d05
[davem@localhost net-next]$ cd ../net
[davem@localhost net]$ git describe 4dfb80d18d05
fatal: Not a valid object name 4dfb80d18d05
[davem@localhost net]$
