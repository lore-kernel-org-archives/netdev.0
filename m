From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tcp: use DSACKs that arrive when packets_out is 0
Date: Sun, 27 Nov 2011 18:55:50 -0500 (EST)
Message-ID: <20111127.185550.78935068183903191.davem@davemloft.net>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
	<1321469885-10885-2-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1111170323560.1205@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab1K0X4C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 18:56:02 -0500
In-Reply-To: <alpine.DEB.2.00.1111170323560.1205@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 17 Nov 2011 03:34:17 +0200 (EET)

> On Wed, 16 Nov 2011, Neal Cardwell wrote:
>=20
>> The bug: Senders ignored DSACKs after recovery when there were no
>> outstanding packets (a common scenario for HTTP servers).
>>=20
>> The change: when there are no outstanding packets (the "no_queue" go=
to
>> label), call tcp_fastretrans_alert() in order to use DSACKs to undo
>> congestion window reductions.
>>=20
>> Other patches in this series will provide other changes that are
>> necessary to fully fix this problem.
>>=20
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next.
