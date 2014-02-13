From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: cpsw: catch of_get_phy_mode failing and propagate
 error
Date: Thu, 13 Feb 2014 19:41:36 +0530
Message-ID: <52FCD298.5050005@ti.com>
References: <1392244402-24823-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kernel@pengutronix.de>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:43899 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbaBMOLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 09:11:55 -0500
In-Reply-To: <1392244402-24823-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 13 February 2014 04:03 AM, Uwe Kleine-K=C3=B6nig wrote:
> It's wrong if the device tree doesn't provide a phy-mode property for
> the cpsw slaves as it is documented to be required in
> Documentation/devicetree/bindings/net/cpsw.txt.
>
> Anyhow it's nice to catch that problem, still more as it used to work
> without this property up to commit 388367a5a9fb (drivers: net: cpsw: =
use
> cpsw-phy-sel driver to configure phy mode) which is in v3.13-rc1.
>
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Good catch

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
