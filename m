From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] ipv6: pointer math error in ip6_tnl_parse_tlv_enc_lim()
Date: Wed, 01 Feb 2017 07:26:17 -0800
Message-ID: <1485962777.6360.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170201084632.GA29912@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36526 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdBAP0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 10:26:22 -0500
In-Reply-To: <20170201084632.GA29912@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 11:46 +0300, Dan Carpenter wrote:
> Casting is a high precedence operation but "off" and "i" are in terms of
> bytes so we need to have some parenthesis here.
> 
> Fixes: fbfa743a9d2a ("ipv6: fix ip6_tnl_parse_tlv_enc_lim()")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Silly me. Thanks Dan !

Acked-by: Eric Dumazet <edumazet@google.com>
