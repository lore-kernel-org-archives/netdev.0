From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] net: cdc_ncm: fix buffer overflow
Date: Mon, 05 May 2014 15:20:37 -0400 (EDT)
Message-ID: <20140505.152037.455988814617308575.davem@davemloft.net>
References: <1399066020-22748-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	alexey.orishko@gmail.com, oliver@neukum.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaEETUk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:20:40 -0400
In-Reply-To: <1399066020-22748-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri,  2 May 2014 23:27:00 +0200

> Commit 4d619f625a60 ("net: cdc_ncm: no point in filling up the NTBs
> if we send ZLPs") changed the padding logic for devices with the ZLP
> flag set.  This meant that frames of any size will be sent without
> additional padding, except for the single byte added if the size is
> a multiple of the USB packet size. But if the unpadded size is
> identical to the maximum frame size, and the maximum size is a
> multiplum of the USB packet size, then this one-byte padding will
> overflow the buffer.
>=20
> Prevent padding if already at maximum frame size, letting usbnet
> transmit a ZLP instead in this case.
>=20
> Fixes: 4d619f625a60 ("net: cdc_ncm: no point in filling up the NTBs i=
f we send ZLPs")
> Reported by: Yu-an Shih <yshih@nvidia.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
> Please add this to the stable v3.13 and v3.14 queues as well.  Thanks=
=2E

Applied and queued up for -stable, thanks.
