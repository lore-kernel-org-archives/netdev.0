From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Make snd_cwnd_cnt 32-bit
Date: Mon, 15 Oct 2007 13:01:16 -0700 (PDT)
Message-ID: <20071015.130116.24317163.davem@davemloft.net>
References: <Pine.LNX.4.64.0710151856340.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756073AbXJOUBM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 16:01:12 -0400
In-Reply-To: <Pine.LNX.4.64.0710151856340.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 15 Oct 2007 18:57:31 +0300 (EEST)

>=20
> Very little point of having 32-bit snd_cnwd if this is not
> 32-bit as well, as a number of snd_cwnd incrementation formulas
> assume that snd_cwnd_cnt can be at least as large as snd_cwnd.
>=20
> Whether 32-bit is useful was discussed when e0ef57cc56c3c96
> was made:
>   http://marc.info/?l=3Dlinux-netdev&m=3D117218144409825&w=3D2
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, and I intend to push this to -stable as well.

Thanks!
