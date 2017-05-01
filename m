From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: bridge: Fix improper taking over HW
 learned FDB
Date: Sun, 30 Apr 2017 22:46:52 -0400 (EDT)
Message-ID: <20170430.224652.1616918504779575655.davem@davemloft.net>
References: <1493408347-44779-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, idosch@mellanox.com,
        nikolay@cumulusnetworks.com
To: arkadis@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951781AbdEACqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:46:54 -0400
In-Reply-To: <1493408347-44779-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>
Date: Fri, 28 Apr 2017 22:39:07 +0300

> Commit 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb
> entries") added the ability to "take over an entry which was previously
> learned via HW when it shows up from a SW port".
> 
> However, if an entry was learned via HW and then a control packet
> (e.g., ARP request) was trapped to the CPU, the bridge driver will
> update the entry and remove the externally learned flag, although the
> entry is still present in HW. Instead, only clear the externally learned
> flag in case of roaming.
> 
> Fixes: 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb entries")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Arkadi Sharashevsky <arkadis@mellanox.com>

Applied, thanks.
