From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: qmi_wwan: fixup Sierra Wireless MC8305 entry
Date: Mon, 01 Jul 2013 17:01:52 -0700 (PDT)
Message-ID: <20130701.170152.867504071219990432.davem@davemloft.net>
References: <1372432671-17283-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287Ab3GBABx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 20:01:53 -0400
In-Reply-To: <1372432671-17283-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 28 Jun 2013 17:17:49 +0200

> The MC8305 module got an additional entry added based solely on
> information from a Windows driver *.inf file. We now have the
> actual descriptor layout from one of these modules, and it
> consists of two alternate configurations where cfg #1 is a
> normal Gobi 2k layout and cfg #2 is MBIM only, using interface
> numbers 5 and 6 for MBIM control and data. The extra Windows
> driver entry for interface number 5 was most likely a bug.
>=20
> Deleting the bogus entry to avoid unnecessary qmi_wwan probe
> failures when using the MBIM configuration.
>=20
> Reported-by: Lana Black <sickmind@lavabit.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
