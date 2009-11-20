From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:40:46 -0800
Message-ID: <20091120154046.67252d23@nehalam>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58105 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438AbZKTXlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 18:41:02 -0500
In-Reply-To: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Nov 2009 15:28:58 -0800
Tom Herbert <therbert@google.com> wrote:

> +static char *get_token(const char **cp, size_t *len)
> +{
> +	const char *bp = *cp;
> +	char *start;
> +
> +	while (isspace(*bp))
> +		bp++;
> +
> +	start = (char *)bp;
> +	while (!isspace(*bp) && *bp != '\0')
> +		bp++;
> +
> +	if (start != bp)
> +		*len = bp - start;
> +	else
> +		start = NULL;
> +
> +	*cp = bp;
> +	return start;
> +}


Sysfs is intentionally one value per file. If you need multiple
values, then it is the wrong interface.

-- 
