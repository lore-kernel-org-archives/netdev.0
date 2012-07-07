From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix non-ANSI function declaration warning
Date: Sat, 7 Jul 2012 20:57:29 +0100
Message-ID: <1341691049.25597.169.camel@deadeye.wl.decadent.org.uk>
References: <1341686871-21822-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <mirq-linux@rere.qmqm.pl>,
	<jpirko@redhat.com>, <therbert@google.com>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Emil Goode <emilgoode@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48866 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751187Ab2GGT5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 15:57:33 -0400
In-Reply-To: <1341686871-21822-1-git-send-email-emilgoode@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-07 at 20:47 +0200, Emil Goode wrote:
> Sparse is warning about non-ANSI function declaration.
> Add void to the parameterless function.
> 
> net/core/dev.c:1804:38: warning:
> 	non-ANSI function declaration of function
> 	'netif_get_num_default_rss_queues'

I also posted a patch for this (and another instance I found).

Ben.

> Signed-off-by: Emil Goode <emilgoode@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 07c1251..fc6fbce 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1801,7 +1801,7 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
>   * This routine should set an upper limit on the number of RSS queues
>   * used by default by multiqueue devices.
>   */
> -int netif_get_num_default_rss_queues()
> +int netif_get_num_default_rss_queues(void)
>  {
>  	return min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
