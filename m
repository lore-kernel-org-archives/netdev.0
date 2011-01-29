From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: implement G/SFEATURES calls
Date: Sun, 30 Jan 2011 08:47:35 +1000
Message-ID: <1296341255.3477.67.camel@localhost>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
	 <4d4fee145908eb232f2766b7d8cbfebaeeffc5e5.1296325736.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17453 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab1A2Wrh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 17:47:37 -0500
In-Reply-To: <4d4fee145908eb232f2766b7d8cbfebaeeffc5e5.1296325736.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-29 at 19:39 +0100, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> @@ -196,8 +202,8 @@ static struct option {
>  		"		[ rx-mini N ]\n"
>  		"		[ rx-jumbo N ]\n"
>  	        "		[ tx N ]\n" },
> -    { "-k", "--show-offload", MODE_GOFFLOAD, "Get protocol offload i=
nformation" },
> -    { "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload",
> +    { "-k", "--show-offload", MODE_GOFFLOAD, "Get protocol offload i=
nformation (deprecated)" },
> +    { "-K", "--offload", MODE_SOFFLOAD, "Set protocol offload (depre=
cated)",
>  		"		[ rx on|off ]\n"
>  		"		[ tx on|off ]\n"
>  		"		[ sg on|off ]\n"
[...]

I see no reason to deprecate the existing options.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

