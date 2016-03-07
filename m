From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] cdc_ncm: toggle altsetting to force reset
 before setup
Date: Mon, 07 Mar 2016 14:38:11 -0500 (EST)
Message-ID: <20160307.143811.474380372887861694.davem@davemloft.net>
References: <1457040053-25271-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oliver@neukum.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbcCGTiN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:38:13 -0500
In-Reply-To: <1457040053-25271-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu,  3 Mar 2016 22:20:53 +0100

> Some devices will silently fail setup unless they are reset first.
> This is necessary even if the data interface is already in
> altsetting 0, which it will be when the device is probed for the
> first time.  Briefly toggling the altsetting forces a function
> reset regardless of the initial state.
>=20
> This fixes a setup problem observed on a number of Huawei devices,
> appearing to operate in NTB-32 mode even if we explicitly set them
> to NTB-16 mode.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable, thanks.
