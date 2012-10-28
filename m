From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cdc_ncm: big endian fix
Date: Sun, 28 Oct 2012 19:08:32 -0400 (EDT)
Message-ID: <20121028.190832.835396326917069506.davem@davemloft.net>
References: <1351237449-23643-1-git-send-email-bjorn@mork.no>
	<1351237449-23643-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	oliver@neukum.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab2J1XId convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 19:08:33 -0400
In-Reply-To: <1351237449-23643-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 26 Oct 2012 09:44:08 +0200

> Probably doesn't matter much since the value is used as a
> boolean anyway, but it removes the sparse warning:
>=20
>  drivers/net/usb/cdc_ncm.c:1090:32: warning: incorrect type in assign=
ment (different base types)
>  drivers/net/usb/cdc_ncm.c:1090:32:    expected unsigned short [unsig=
ned] [usertype] connected
>  drivers/net/usb/cdc_ncm.c:1090:32:    got restricted __le16 [usertyp=
e] wValue
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
