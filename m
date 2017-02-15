From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 10/13] net: ethernet: aquantia: Checking for
 success dma_map_single.
Date: Wed, 15 Feb 2017 22:40:23 +0100
Message-ID: <f52f06ff-0666-865a-74b5-e7840fde3a3c@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <6ad9fef330a2c9b59139621efbb7c77e746d9f25.1487187192.git.pavel.belous@aquantia.com>
 <60f99adb-f29f-1527-0a0a-406c39c99d0f@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:51695 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752583AbdBOVkh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:40:37 -0500
In-Reply-To: <60f99adb-f29f-1527-0a0a-406c39c99d0f@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 22:23, Lino Sanfilippo wrote:

>
>
> In case of this error you have to undo all mappings that you have
> done so far (i.e the complete frag list and the head buffer).
>

And, since mapping failed, set ret = 0 and handle this case in the
caller, too.

Regards,
Lino
