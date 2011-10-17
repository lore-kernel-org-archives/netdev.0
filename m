From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: update CAN bitrate SJW help text
Date: Mon, 17 Oct 2011 08:58:26 -0700
Message-ID: <20111017085826.7a62ed11@nehalam.linuxnetplumber.net>
References: <4E9C4D29.7010302@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55860 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187Ab1JQP6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:58:30 -0400
In-Reply-To: <4E9C4D29.7010302@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 17:43:37 +0200
Oliver Hartkopp <socketcan@hartkopp.net> wrote:

> The ip-tool from iproute2 already supports to pass a user defined SJW
> value for the in-kernel bittiming calculation. This patch updates the
> help text accordingly.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> ---
> 
> diff --git a/ip/iplink_can.c b/ip/iplink_can.c
> index c8af4bc..00e7d98 100644
> --- a/ip/iplink_can.c
> +++ b/ip/iplink_can.c
> @@ -23,7 +23,8 @@ static void usage(void)
>  {
>  	fprintf(stderr,
>  		"Usage: ip link set DEVICE type can\n"
> -	        "\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
> +		"\t[ bitrate BITRATE [ sample-point SAMPLE-POINT ] [ sjw SJW "
> +		"] ] | \n"
>  	        "\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
>  		"\t  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]\n"
>  		"\n"

Please update man page as well.
