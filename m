From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: lower stack usage in efx_ethtool_self_test
Date: Mon, 21 Feb 2011 16:09:21 +0000
Message-ID: <1298304561.2608.41.camel@bwh-desktop>
References: <1297800733.2584.15.camel@bwh-desktop>
	 <1297864118.3201.354.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53608 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab1BUQJX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 11:09:23 -0500
In-Reply-To: <1297864118.3201.354.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-16 at 14:48 +0100, Eric Dumazet wrote:
> drivers/net/sfc/ethtool.c: In function =E2=80=98efx_ethtool_self_test=
=E2=80=99:
> drivers/net/sfc/ethtool.c:613: warning: the frame size of 1200 bytes
> is larger than 1024 bytes

This also fixes a whopping information leak in case the device is in a
broken state.

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

