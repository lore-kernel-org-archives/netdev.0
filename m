From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ss: Report MSS from internal TCP information
Date: Tue, 31 Jul 2012 14:07:15 -0700
Message-ID: <20120731140715.1dc3cd1b@nehalam.linuxnetplumber.net>
References: <1343677867.2667.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59756 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139Ab2GaVHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 17:07:40 -0400
In-Reply-To: <1343677867.2667.33.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jul 2012 20:51:07 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  misc/ss.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index cf529ef..8ad830b 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1392,6 +1392,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
>  			       (double)info->tcpi_rttvar/1000);
>  		if (info->tcpi_ato)
>  			printf(" ato:%g", (double)info->tcpi_ato/1000);
> +		if (info->tcpi_snd_mss)
> +			printf(" mss:%d", info->tcpi_snd_mss);
>  		if (info->tcpi_snd_cwnd != 2)
>  			printf(" cwnd:%d", info->tcpi_snd_cwnd);
>  		if (info->tcpi_snd_ssthresh < 0xFFFF)

Applied
