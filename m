From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sat, 13 Sep 2014 23:21:53 +0300
Message-ID: <5414A761.7070200@cogentembedded.com>
References: <54137F59.4040904@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:50342 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbaIMUSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:18:53 -0400
Received: by mail-we0-f171.google.com with SMTP id p10so2285485wes.2
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 13:18:52 -0700 (PDT)
In-Reply-To: <54137F59.4040904@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2014 2:18 AM, David L Stevens wrote:

> This patch allows an admin to set the MTU on a sunvnet device to arbitrary
> values between the minimum (68) and maximum (65535) IPv4 packet sizes.

> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---
>   drivers/net/ethernet/sun/sunvnet.c |    6 +++++-
>   drivers/net/ethernet/sun/sunvnet.h |    2 +-
>   2 files changed, 6 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index a6418bb..b557ec4 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -751,6 +751,10 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	if (unlikely(!port))
>   		goto out_dropped;
>
> +	if (skb->len > port->vio.rmtu) {
> +		goto out_dropped;
> +	}

    {} not needed.

[...]

WBR, Sergei
