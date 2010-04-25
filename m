From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH v2] TCP: avoid to send keepalive probes if it is
 receiving data
Date: Sun, 25 Apr 2010 20:55:49 -0300
Message-ID: <20100425235549.GB2550@sysclose.org>
References: <1271602519-6805-1-git-send-email-fleitner@redhat.com>
 <1271610919.16881.5564.camel@edumazet-laptop>
 <alpine.DEB.2.00.1004182328370.19304@melkinpaasi.cs.helsinki.fi>
 <20100421.224205.18551946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcahe.dreamhost.com ([208.97.132.74]:50808 "EHLO
	homiemail-a15.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752384Ab0DYX4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 19:56:08 -0400
Content-Disposition: inline
In-Reply-To: <20100421.224205.18551946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 10:42:05PM -0700, David Miller wrote:
> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sun, 18 Apr 2010 23:34:15 +0300 (EEST)
>=20
> > I fail to see why the addition of this new variable is necessary at=
 all,=20
> > could either of you enlight me why exactly it's necessary and rcv_t=
stamp=20
> > will not suffice?
>=20
> I agree, the existing rcv_tstamp should serve this purpose just
> fine.

I thought it would break TCP_INFO/tcp_get_info(). Actually, reviewing
the code again I found another variable which does exactly what is need=
ed.

I'll post a new patch for review.

thanks,
--=20
=46lavio
