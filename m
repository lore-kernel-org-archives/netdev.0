From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: ieee802154: fix potential null pointer dereference
Date: Tue, 23 May 2017 11:13:35 -0700
Message-ID: <1B82BF85-7AA5-4A52-B0A8-7336DE963567@holtmann.org>
References: <20170523181147.GA32714@embeddedgus>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:42873 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967057AbdEWSNm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 14:13:42 -0400
In-Reply-To: <20170523181147.GA32714@embeddedgus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gustavo,

> Null check at line 918: if (!spi) {, implies spi might be NULL.
> Function spi_get_drvdata() dereference pointer spi.
> Move pointer priv assignment after the null check.
> 
> Addresses-Coverity-ID: 1408888
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> drivers/net/ieee802154/ca8210.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
