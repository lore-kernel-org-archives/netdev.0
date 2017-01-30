From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Paritially checksum full MTU frames
Date: Mon, 30 Jan 2017 15:51:26 -0500 (EST)
Message-ID: <20170130.155126.1842306899158752940.davem@davemloft.net>
References: <1485748373-14909-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754449AbdA3Uv2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:51:28 -0500
In-Reply-To: <1485748373-14909-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Sun, 29 Jan 2017 22:52:53 -0500

> IPv6 will mark data that is smaller that mtu - headersize as
> CHECKSUM_PARTIAL, but if the data will completely fill the mtu,
> the packet checksum will be computed in software instead.
> Extend the conditional to include the data that fills the mtu
> as well.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Looks good, applied, thanks!
