From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] bridge: mark packets sent to any local mac address as
 PACKET_HOST
Date: Thu, 26 Jun 2014 23:19:48 +0200
Message-ID: <20140626211948.GA7077@sakura.staff.proxad.net>
References: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
 <20140625161335.11598f09@haswell>
 <1403781352.52578.103.camel@sakura.staff.proxad.net>
 <20140626.133550.975175623908419742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:54400 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbaFZVTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 17:19:53 -0400
Content-Disposition: inline
In-Reply-To: <20140626.133550.975175623908419742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 26 Jun 2014 =E0 13:35:50 (-0700), David Miller wrote:

> > for some reasons, hostapd kept adding and removing the interface fr=
om
> > the bridge, triggering a mac address of the bridge change each time=
 (I
> > did not notice that).
>=20
> I think this is what you need to investigate rather than making
> changes to the bridge layer.

Of course I fixed the problem with hostapd, I was just explaining how
I noticed that behaviour in the bridge code.

If that behaviour is intended then just forget that patch.

--=20
Maxime
