From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 2/3] iproute: add support for SRv6
 local segment processing
Date: Wed, 9 Aug 2017 07:43:16 -0700
Message-ID: <20170809074316.3acaafa1@xeon-e3>
References: <20170809131701.21304-1-david.lebrun@uclouvain.be>
        <20170809131701.21304-3-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37134 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751972AbdHIOnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 10:43:20 -0400
Received: by mail-pg0-f42.google.com with SMTP id y129so28945411pgy.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 07:43:20 -0700 (PDT)
In-Reply-To: <20170809131701.21304-3-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Aug 2017 15:17:00 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +
> +static int read_action_type(const char *name)
> +{
> +	if (strcmp(name, "End") == 0)
> +		return SEG6_LOCAL_ACTION_END;
> +	else if (strcmp(name, "End.X") == 0)
> +		return SEG6_LOCAL_ACTION_END_X;
> +	else if (strcmp(name, "End.T") == 0)
> +		return SEG6_LOCAL_ACTION_END_T;
> +	else if (strcmp(name, "End.DX2") == 0)
> +		return SEG6_LOCAL_ACTION_END_DX2;
> +	else if (strcmp(name, "End.DX6") == 0)
> +		return SEG6_LOCAL_ACTION_END_DX6;
> +	else if (strcmp(name, "End.DX4") == 0)
> +		return SEG6_LOCAL_ACTION_END_DX4;
> +	else if (strcmp(name, "End.DT6") == 0)
> +		return SEG6_LOCAL_ACTION_END_DT6;
> +	else if (strcmp(name, "End.DT4") == 0)
> +		return SEG6_LOCAL_ACTION_END_DT4;
> +	else if (strcmp(name, "End.B6") == 0)
> +		return SEG6_LOCAL_ACTION_END_B6;
> +	else if (strcmp(name, "End.B6.Encaps") == 0)
> +		return SEG6_LOCAL_ACTION_END_B6_ENCAP;
> +	else if (strcmp(name, "End.BM") == 0)
> +		return SEG6_LOCAL_ACTION_END_BM;
> +	else if (strcmp(name, "End.S") == 0)
> +		return SEG6_LOCAL_ACTION_END_S;
> +	else if (strcmp(name, "End.AS") == 0)
> +		return SEG6_LOCAL_ACTION_END_AS;
> +	else if (strcmp(name, "End.AM") == 0)
> +		return SEG6_LOCAL_ACTION_END_AM;
> +
> +	return SEG6_LOCAL_ACTION_UNSPEC;
> +}

Why is this not a table instead of code?
