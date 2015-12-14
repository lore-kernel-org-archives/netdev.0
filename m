From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 4/4] net: diag: Support destroying TCP sockets.
Date: Mon, 14 Dec 2015 14:37:39 -0500 (EST)
Message-ID: <20151214.143739.879220917312503422.davem@davemloft.net>
References: <CALx6S37SvPk319=hC8mVwLHsa8T_6wed41wcqLgudR8yj3akdg@mail.gmail.com>
	<1450114197-73779-1-git-send-email-lorenzo@google.com>
	<1450114197-73779-5-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127AbbLNThk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:37:40 -0500
In-Reply-To: <1450114197-73779-5-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 15 Dec 2015 02:29:57 +0900

> +#if CONFIG_INET_DIAG_DESTROY

Config symbols are to be checked with "ifdef" not "if".

> +config INET_DIAG_DESTROY
> +	bool "INET: allow privileged process to administratively close sockets"
> +	depends on INET_DIAG && (IPV6 || IPV6=n)
> +	default n

As Eric Dumazet stated, this "(X || X=n)" construct only makes sense for
tristate Kconfig entries.
