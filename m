From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] Revert recent TCP work
Date: Sun, 16 Dec 2007 14:21:52 -0800 (PST)
Message-ID: <20071216.142152.187297327.davem@davemloft.net>
References: <47616FA6.1010607@fr.ibm.com>
	<Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0712141946060.1400@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, clg@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	reuben-linuxkernel@reub.net, kamalesh@linux.vnet.ibm.com,
	riel@redhat.com, dhaval@linux.vnet.ibm.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757530AbXLPWV6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 17:21:58 -0500
In-Reply-To: <Pine.LNX.4.64.0712141946060.1400@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 14 Dec 2007 22:14:29 +0200 (EET)

> Could you either drop my recent patches (+one fix to them from Herber=
t
> Xu =3D=3D "[TCP]: Fix crash in tcp_advance_send_head"), all mine afte=
r "[TCP]:=20
> Abstract tp->highest_sack accessing & point to next skb" from net-2.6=
=2E25=20
> or just apply the revert from below and do the removal during next re=
base.=20
> I think it could even be automated by something like this (untested):
> for i in $(cat commits | cut -d ' ' -f 1); do git-rebase --onto $i^ $=
i; done=20
> (I've attached the commits list).

I'll take care of this when I rebase the net-2.6.25 tree later
today.

Thanks Ilpo.
