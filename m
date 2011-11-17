From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/3] team: replicate options on register
Date: Thu, 17 Nov 2011 09:32:16 +0100
Message-ID: <1321518736.3274.45.camel@edumazet-laptop>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
	 <1321477749-1877-4-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48040 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094Ab1KQIcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:32:22 -0500
Received: by wwe5 with SMTP id 5so2452861wwe.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 00:32:21 -0800 (PST)
In-Reply-To: <1321477749-1877-4-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 novembre 2011 =C3=A0 22:09 +0100, Jiri Pirko a =C3=A9cri=
t :

> +
> +int team_options_register(struct team *team,
> +			  const struct team_option *option,
> +			  size_t option_count)
>  {
>  	int i;
> +	struct team_option *dst_opts[option_count];
> +	int err;

This kind of construct will trigger static analyzer alerts...
