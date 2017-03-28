From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] 6lowpan: set peer_addr correctly again
Date: Tue, 28 Mar 2017 15:37:00 +0200
Message-ID: <368A8A18-0B9B-4733-86EF-D44C8E9CAE36@holtmann.org>
References: <20170328132935.382216-1-arnd@arndb.de>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Luiz Augusto von Dentz <luiz.von.dentz@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        Patrik Flykt <patrik.flykt@linux.intel.com>,
        Alexander Aring <aar@pengutronix.de>,
        Glenn Ruben Bakke <glennrubenbakke@nordicsemi.no>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:51975 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdC1Nhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:37:46 -0400
In-Reply-To: <20170328132935.382216-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

> A bugfix accidentally changed one line to return the peer_addr
> from setup_header, causing it to become unused:
> 
> net/bluetooth/6lowpan.c: In function 'setup_header':
> net/bluetooth/6lowpan.c:402:14: error: parameter 'peer_addr' set but not used [-Werror=unused-but-set-parameter]
> 
> The only user of the variable is a subsequent printk(), and
> it is not otherwise initialized, so reverting the changed line
> looks like the right fix.
> 
> Fixes: fb6f2f606ce8 ("6lowpan: Fix IID format for Bluetooth")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> net/bluetooth/6lowpan.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

I took Colin’s patch since it showed up first in my inbox.

Regards

Marcel
