From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH net-next 6/6] 6lowpan: fix set not used warning
Date: Tue, 25 Jul 2017 15:45:16 +0300
Message-ID: <CABBYNZJES2ph8SkAisPEm-wsZ6iHjKTYkZ9wffhkk7X6=eKGoA@mail.gmail.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com> <20170724172523.13135-7-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        David Miller <davem@davemloft.net>, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33376 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdGYMpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 08:45:18 -0400
In-Reply-To: <20170724172523.13135-7-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Mon, Jul 24, 2017 at 8:25 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  net/bluetooth/6lowpan.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 2af4f1cc0ab4..4e2576fc0c59 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -273,9 +273,6 @@ static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
>                            struct lowpan_peer *peer)
>  {
>         const u8 *saddr;
> -       struct lowpan_btle_dev *dev;
> -
> -       dev = lowpan_btle_dev(netdev);
>
>         saddr = peer->lladdr;
>
> --
> 2.11.0

Acked-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

-- 
Luiz Augusto von Dentz
