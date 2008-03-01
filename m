From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC [PATCH 0/3] TCP_DEFER_ACCEPT updates
Date: Sat, 01 Mar 2008 11:41:19 +0100
Message-ID: <47C932CF.70203@cosmosbay.com>
References: <1204076936.15970.33.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev@vger.kernel.org
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:48894
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751474AbYCAKlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 05:41:32 -0500
In-Reply-To: <1204076936.15970.33.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McManus a =E9crit :
> Hello,
>=20
> I have a few patches to try and improve the TCP_DEFER_ACCEPT
> implementation. The first two are simple, the third is ante for a
> discussion on how this should really be implemented.
>=20
> Patch 1 : timeout values could not be less than allowed by the max
> syn-recv queue size algorithms. This was not simply a matter of round=
ing
> up to the next syn-ack retransmit time, it was enforcing at least 5
> retransmits on a non-loaded machine even if the timeout (expressed by
> the API in seconds) was set to 1.
>=20
> Patch 2 : a socket that has completed its handshake but which is wait=
ing
> for the first data packet was retransmitting its syn-ack during that
> period. This patch suppresses that transmission.
>=20
> Patch 3 : move the connected (and TCP_DEFER'd) socket to ESTABLISHED
> after the handshake, but defer placing it in the accept queue until s=
ome
> data arrives.=20
>=20
> RFC?
>=20

I like your patches Patrick :)

