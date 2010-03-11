From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] net: tcp: make hybla selectable as default
 congestion module
Date: Thu, 11 Mar 2010 12:10:32 -0800
Message-ID: <20100311121032.3b9213e1@nehalam>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	<1268337450-6749-2-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50511 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758163Ab0CKULA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:11:00 -0500
In-Reply-To: <1268337450-6749-2-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 20:57:27 +0100
Jan Engelhardt <jengelh@medozas.de> wrote:

> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
>  net/ipv4/Kconfig |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 0c94a1a..731c47b 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -587,6 +587,9 @@ choice
>  	config DEFAULT_HTCP
>  		bool "Htcp" if TCP_CONG_HTCP=y
>  
> +	config DEFAULT_HYBLA
> +		bool "Hybla" if TCP_CONG_HYBLA=y
> +
>  	config DEFAULT_VEGAS
>  		bool "Vegas" if TCP_CONG_VEGAS=y
>  
> @@ -610,6 +613,7 @@ config DEFAULT_TCP_CONG
>  	default "bic" if DEFAULT_BIC
>  	default "cubic" if DEFAULT_CUBIC
>  	default "htcp" if DEFAULT_HTCP
> +	default "hybla" if DEFAULT_HYBLA
>  	default "vegas" if DEFAULT_VEGAS
>  	default "westwood" if DEFAULT_WESTWOOD
>  	default "reno" if DEFAULT_RENO

Hybla seems too experimental to be made default.
