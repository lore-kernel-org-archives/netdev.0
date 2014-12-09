From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: dsa: replacing the hard-coded sized array
 "dsa_switch" by dynamic one
Date: Tue, 09 Dec 2014 14:45:30 -0500 (EST)
Message-ID: <20141209.144530.1288294855056564069.davem@davemloft.net>
References: <547DD1C6.2090304@nexvision.fr>
	<547E23C1.2040007@gmail.com>
	<548083B8.5090900@nexvision.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrey.volkov@nexvision.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbaLITpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:45:33 -0500
In-Reply-To: <548083B8.5090900@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Volkov <andrey.volkov@nexvision.fr>
Date: Thu, 04 Dec 2014 16:54:32 +0100

> @@ -732,7 +730,8 @@ static int dsa_probe(struct platform_device *pdev)
>          goto out;
>      }
>  
> -    dst = kzalloc(sizeof(*dst), GFP_KERNEL);
> +    dst = kzalloc(sizeof(*dst) +
> +            sizeof(struct dsa_switch *) * pd->nr_chips, GFP_KERNEL);

Your email client has completely corrupted your patch.  For one thing it
has transformed TAB characters into spaces.

Please read Documentation/email-clients.txt, email the patch to yourself,
and then try to successfully apply the patch you receive in that email.
If it doesn't work for you, it won't work for us either.

Do not resubmit this patch until your have fully resolved this, thanks.
