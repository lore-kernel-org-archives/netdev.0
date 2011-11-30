From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] caif: Remove unused enum and parameter in
 cfserl
Date: Wed, 30 Nov 2011 17:04:57 -0500 (EST)
Message-ID: <20111130.170457.1002117290486935116.davem@davemloft.net>
References: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322680968-6470-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1K3WFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:05:03 -0500
In-Reply-To: <1322680968-6470-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Wed, 30 Nov 2011 20:22:48 +0100

>  			link_support =3D cfserl_create(dev->ifindex,
> -					CFPHYTYPE_FRAG, caifdev->use_stx);
> +							caifdev->use_stx);
>  			if (!link_support) {
>  				pr_warn("Out of memory\n");
>  				break;
 ...
> -struct cflayer *cfserl_create(int type, int instance, bool use_stx)
> +struct cflayer *cfserl_create(int instance, bool use_stx)
>  {

Looks like this code was always buggy, passing the index in the type pa=
rameter
and the type in the instance parameter.
