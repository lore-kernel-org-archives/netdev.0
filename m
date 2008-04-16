From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [TCP]: Remove superflushious skb ==
 write_queue_tail() check
Date: Tue, 15 Apr 2008 20:37:32 -0700 (PDT)
Message-ID: <20080415.203732.193684222.davem@davemloft.net>
References: <Pine.LNX.4.64.0804151206010.17123@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752939AbYDPDhb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 23:37:31 -0400
In-Reply-To: <Pine.LNX.4.64.0804151206010.17123@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 15 Apr 2008 12:06:47 +0300 (EEST)

>=20
> Needed can only be more strict than what was checked by the
> earlier common case check for non-tail skbs, thus
> cwnd_len <=3D needed will never match in that case anyway.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.26, thanks Ilpo.
