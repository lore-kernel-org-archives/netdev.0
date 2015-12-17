From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: qmi_wwan: ignore bogus CDC Union
 descriptors
Date: Thu, 17 Dec 2015 16:11:47 -0500 (EST)
Message-ID: <20151217.161147.240813389546052178.davem@davemloft.net>
References: <1450352644-12445-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Topi.Kanerva@cinia.fi,
	linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933347AbbLQVLt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 16:11:49 -0500
In-Reply-To: <1450352644-12445-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 17 Dec 2015 12:44:04 +0100

> The CDC descriptors found on these vendor specific functions should
> not be considered authoritative.  They seem to be ignored by drivers
> for other systems, and the quality is therefore low.
>=20
> One device (1e0e:9001) has been reported to have such a bogus union
> descriptor on the QMI function, making it fail probing even if the
> device id was dynamically added.  The report was not complete enough
> to allow adding a device entry for this modem. But this should at
> least fix the dynamic id probing problem.
>=20
> Reported-by: Kanerva Topi <Topi.Kanerva@cinia.fi>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks!
