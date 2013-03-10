From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] print_rate: use knowledge in rate_suffix table for
 human readable rates.
Date: Sat, 09 Mar 2013 20:08:41 -0800
Message-ID: <1362888521.4051.6.camel@edumazet-glaptop>
References: <1362885998-14292-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:44658 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab3CJEIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:08:45 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so1702565eek.13
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:08:44 -0800 (PST)
In-Reply-To: <1362885998-14292-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-09 at 19:26 -0800, Vimalkumar wrote:
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  tc/tc_util.c |   26 ++++++++++++--------------
>  1 files changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index 0939536..6e68d87 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -139,7 +139,8 @@ static const struct rate_suffix {
>  	{ "GBps",	8000000000. },
>  	{ "TiBps",	8.*1024.*1024.*1024.*1024. },
>  	{ "TBps",	8000000000000. },
> -	{ NULL }
> +	{ NULL },
> +	{ NULL },
>  };
>  

You'll have to explicitly add in the title a way to say its a patch for
iproute2.

[PATCH iproute2] tc:  use knowledge in rate_suffix table for human readable rates.

To avoid the confusion, as netdev is more likely to review kernel patches.
