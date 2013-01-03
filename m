From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] DSA: Convert DSA driver comments to network-style
 comments
Date: Wed, 02 Jan 2013 18:05:35 -0800
Message-ID: <1357178735.25181.40.camel@joe-AO722>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
	 <1357178098-4057-2-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Barry Grussling <barry@grussling.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36620 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752757Ab3ACCFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 21:05:37 -0500
In-Reply-To: <1357178098-4057-2-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-02 at 17:54 -0800, Barry Grussling wrote:
> Convert DSA driver comments to network-style comments as reported by
> checkpatch.pl.
[]
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
[]
> @@ -67,26 +67,22 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
>  	int i;
>  	int ret;
>  
> -	/*
> -	 * Set all ports to the disabled state.
> +	/* Set all ports to the disabled state.
>  	 */

This should be one line like:

	/* Set all ports to the disabled state */

> -	/*
> -	 * Wait for transmit queues to drain.
> +	/* Wait for transmit queues to drain.
>  	 */

same, et al...

[]

> -	/*
> -	 * Priorit Override: disable DA, SA and VTU priority override.
> +	/* Priorit Override: disable DA, SA and VTU priority override.

I presume Priorit should be Priority
