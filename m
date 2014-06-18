From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] Support for SCTP_DEFAULT_SNDINFO socket
 option
Date: Wed, 18 Jun 2014 16:33:01 -0700 (PDT)
Message-ID: <20140618.163301.1261423911029627800.davem@davemloft.net>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
	<1403017296-28469-7-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com
To: geirola@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756218AbaFRXdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:33:02 -0400
In-Reply-To: <1403017296-28469-7-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland <geirola@gmail.com>
Date: Tue, 17 Jun 2014 17:01:36 +0200

> +
> +	/* Note! asoc->default_timetolive is not set in this way anymore.
> +	 * The PR-SCTP extension needs to be implemented.
> +    */

This comment is not formatted correctly.

> +	if (asoc) {
> +		asoc->default_stream = info.snd_sid;
> +		asoc->default_flags = info.snd_flags;
> +		asoc->default_ppid = info.snd_ppid;
> +		asoc->default_context = info.snd_context;
> +	} else {
> +		sp->default_stream = info.snd_sid;
> +		sp->default_flags = info.snd_flags;
> +		sp->default_ppid = info.snd_ppid;
> +		sp->default_context = info.snd_context;
> +	}
> +	return 0;
> +}
> +
>  
>  /* 7.1.10 Set Primary Address (SCTP_PRIMARY_ADDR)

Only one empty line between top-level objects in a source file,
thank you.

>   *
> @@ -5063,6 +5115,45 @@ static int sctp_getsockopt_default_send_param(struct sock *sk,
>  
>  	return 0;
>  }
> +static int sctp_getsockopt_default_sndinfo(struct sock *sk,
> +					int len, char __user *optval,

Please one empty line between top level objects in the source file.
