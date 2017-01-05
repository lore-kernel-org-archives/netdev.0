From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net:dsa: check for EPROBE_DEFER from
 dsa_dst_parse()
Date: Thu, 05 Jan 2017 11:40:12 -0500 (EST)
Message-ID: <20170105.114012.736194534944916815.davem@davemloft.net>
References: <1483611013-15013-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdAEQln (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:41:43 -0500
In-Reply-To: <1483611013-15013-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Thu,  5 Jan 2017 11:10:13 +0100

> Since there can be multiple dsa switches stacked together but
> not all of devicetree nodes available at the time of calling
> dsa_dst_parse(), EPROBE_DEFER can be returned by it. When this
> happens, only the last dsa switch has to be deleted by
> dsa_dst_del_ds(), but not the whole list, because next time linux
> cames back to this function it will try to add only the last dsa
> switch which returned EPROBE_DEFER.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied.
