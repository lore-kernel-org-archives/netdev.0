From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 6 Feb 2008 08:50:30 +0100
Message-ID: <20080206075030.GA454@one.firstfloor.org>
References: <20080205220510.09258826@core> <47a91136.24528c0a.1f6d.ffffa476@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48244 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757217AbYBFHPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 02:15:36 -0500
Content-Disposition: inline
In-Reply-To: <47a91136.24528c0a.1f6d.ffffa476@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static __init int init_syncookies(void)
> +{
> +	get_random_bytes(syncookie_secret, sizeof(syncookie_secret));
> +	return 0;
> +}
> +module_init(init_syncookies);

I didn't think a module could have multiple module_inits. Are you
sure that works?

-Andi

