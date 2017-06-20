From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: enable TSO for IPv6
Date: Tue, 20 Jun 2017 15:19:14 -0400 (EDT)
Message-ID: <20170620.151914.536676400653016067.davem@davemloft.net>
References: <20170619163645.28764-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdFTTTQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:19:16 -0400
In-Reply-To: <20170619163645.28764-1-niklas.cassel@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Mon, 19 Jun 2017 18:36:44 +0200

> There is nothing in the IP that prevents us from enabling TSO for IPv6.
> 
> Before patch:
> ftp fe80::2aa:bbff:fecc:1336%eth0
> ftp> get /dev/zero
> 882512708 bytes received in 00:14 (56.11 MiB/s)
> 
> After patch:
> ftp fe80::2aa:bbff:fecc:1336%eth0
> ftp> get /dev/zero
> 1203326784 bytes received in 00:12 (94.52 MiB/s)
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied, thanks.
