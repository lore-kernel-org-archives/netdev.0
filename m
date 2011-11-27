From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tcp: make is_dupack a parameter to
 tcp_fastretrans_alert()
Date: Sun, 27 Nov 2011 18:55:26 -0500 (EST)
Message-ID: <20111127.185526.662815129045480304.davem@davemloft.net>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1111170323020.1205@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab1K0Xzn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 18:55:43 -0500
In-Reply-To: <alpine.DEB.2.00.1111170323020.1205@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 17 Nov 2011 03:23:53 +0200 (EET)

> On Wed, 16 Nov 2011, Neal Cardwell wrote:
>=20
>> Allow callers to decide whether an ACK is a duplicate ACK. This is a
>> prerequisite to allowing fastretrans_alert to be called from new
>> contexts, such as the no_queue and old_ack code paths, from which we
>> have extra info that tells us whether an ACK is a dupack.
>>=20
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next.
