From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ieee802154: fix gcc-4.9 warnings
Date: Tue, 12 Sep 2017 16:22:32 +0200
Message-ID: <08A75C2B-67AA-4347-A7B4-B1574842B19E@holtmann.org>
References: <20170912101636.3811626-1-arnd@arndb.de>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        "David S. Miller" <davem@davemloft.net>,
        Markus Elfring <elfring@users.sourceforge.net>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Florian Westphal <fw@strlen.de>,
        Johannes Berg <johannes.berg@intel.com>,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        Colin Ian King <colin.king@canonical.com>,
        linux-wpan@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:39679 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdILOWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 10:22:35 -0400
In-Reply-To: <20170912101636.3811626-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

> All older compiler versions up to gcc-4.9 produce these
> harmless warnings:
> 
> drivers/net/ieee802154/ca8210.c: In function 'ca8210_skb_tx':
> drivers/net/ieee802154/ca8210.c:1947:9: warning: missing braces around initializer [-Wmissing-braces]
> 
> This changes the syntax to something that works on all versions
> without warnings.
> 
> Fixes: ded845a781a5 ("ieee802154: Add CA8210 IEEE 802.15.4 device driver")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> drivers/net/ieee802154/ca8210.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
