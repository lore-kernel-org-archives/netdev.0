From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 3/3] net: export physical port id via sysfs
Date: Wed, 24 Jul 2013 16:01:18 -0700 (PDT)
Message-ID: <20130724.160118.1940783900135820589.davem@davemloft.net>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
	<1374498317-6442-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3GXXBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:01:19 -0400
In-Reply-To: <1374498317-6442-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 22 Jul 2013 15:05:17 +0200

> +static size_t _format_port_id(char *buf, int buflen,
> +			      const unsigned char *id, int len)
> +{
> +	int i;
> +	char *cp = buf;
> +
> +	for (i = 0; i < len; i++)
> +		cp += scnprintf(cp, buflen - (cp - buf), "%02x", id[i]);
> +	return cp - buf;
> +}

This is "%phN", please use the printf strings we have support for
in the kernel instead of reimplementing them :-)
