From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] iptunnel: Fix compile error in ip/tunnel.c
Date: Mon, 21 Dec 2015 21:34:50 -0800
Message-ID: <20151221213450.2dd96ef2@xeon-e3>
References: <5677DBB6.3070008@iogearbox.net>
	<20151221194131.636F061201@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:22552 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753710AbbLVFfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 00:35:06 -0500
In-Reply-To: <20151221194131.636F061201@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Dec 2015 20:42:56 +0100
Phil Sutter <phil@nwl.cc> wrote:

> I repeatedly failed to get this right, so now I have to clean up my mess
> afterwards.
> 
> Fixes: 7d6aadcd0a1dc ("ip{,6}tunnel: have a shared stats parser/printer")
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/tunnel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/tunnel.c b/ip/tunnel.c
> index 1dd8092..39f825b 100644
> --- a/ip/tunnel.c
> +++ b/ip/tunnel.c
> @@ -208,7 +208,7 @@ void tnl_print_stats(const char *buf)
>  		      tx_bytes, tx_packets, tx_errs, tx_drops,
>  		      tx_fifo, tx_colls, tx_carrier, rx_multi;
>  
> -	if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
> +	if (sscanf(buf, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
>  	           &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
>  	           &rx_fifo, &rx_frame, &rx_multi,
>  	           &tx_bytes, &tx_packets, &tx_errs, &tx_drops,

Applied..
