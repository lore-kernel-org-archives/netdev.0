From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 3/3] net: mvneta: adjust multiline comments to net/ style
Date: Mon, 19 Nov 2012 16:49:24 +0400
Message-ID: <50AA2AD4.6030007@mvista.com>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com> <1353322834-16952-4-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:36950 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab2KSMuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:50:46 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so1044291lag.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 04:50:44 -0800 (PST)
In-Reply-To: <1353322834-16952-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-11-2012 15:00, Thomas Petazzoni wrote:

> As reported by checkpatch, the multiline comments for net/ and
> drivers/net/ have a slightly different format than the one used in the
> rest of the kernel, so we adjust our multiline comments accordingly.

> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>   drivers/net/ethernet/marvell/mvneta.c |   84 ++++++++++++++++-----------------
>   1 file changed, 42 insertions(+), 42 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index a7826f0..d9dadee 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -178,8 +178,7 @@
>   /* Napi polling weight */
>   #define MVNETA_RX_POLL_WEIGHT		64
>
> -/*
> - * The two bytes Marvell header. Either contains a special value used
> +/* The two bytes Marvell header. Either contains a special value used

    Why the heck you're doing this? It's the preferred style, see 
Documentation/CodingStyle, chapter 8.

WBR, Sergei
