From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: Show state names in the 'link help'
 print
Date: Wed, 25 Feb 2015 17:09:50 -0800
Message-ID: <20150225170950.06b81a78@urahara>
References: <1424908593-4524-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:32898 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbbBZBJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 20:09:48 -0500
Received: by iecar1 with SMTP id ar1so10102087iec.0
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:09:47 -0800 (PST)
In-Reply-To: <1424908593-4524-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 01:56:33 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  bridge/link.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/bridge/link.c b/bridge/link.c
> index a7bd85f..7f1ec70 100644
> --- a/bridge/link.c
> +++ b/bridge/link.c
> @@ -228,6 +228,12 @@ static void usage(void)
>  	fprintf(stderr,	"                               [ flood {on | off} ]\n");
>  	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
>  	fprintf(stderr, "       bridge link show [dev DEV]\n");
> +	fprintf(stderr, "\n");
> +	fprintf(stderr, "STATE := { 0 | disabled   |\n");
> +	fprintf(stderr, "           1 | listening  |\n");
> +	fprintf(stderr, "           2 | learning   |\n");
> +	fprintf(stderr, "           3 | forwarding |\n");
> +	fprintf(stderr, "           4 | blocking }\n");
>  	exit(-1);
>  }
>  

that is too wordy for help. put it in docs if needed.
