From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Wed, 1 Oct 2008 13:27:10 -0300
Message-ID: <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:49316 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYJAQ1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:27:21 -0400
Received: by an-out-0708.google.com with SMTP id d40so36787and.103
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 09:27:18 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008 15:52:19 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Hi Daniel,
>=20
> I forward part of the details to public knowledge (and for Thomas mai=
nly).
>=20
> I also put the epoll & accept only log available for him at
> http://www.cs.helsinki.fi/u/ijjarvin/tcp/epoll_accept.txt
> as it won't contain encryption key, etc. related bits.
>=20
> Can you Daniel please confirm what exactly was the status about the e=
ffect=20
> of disabling ntpd?

	Hi Ilpo, ok, thanks. Following suggestion of kernel developers
from bugzilla, I tested with 2.6.27-rc7 and 2.6.27-rc8. The problem
happens less frequently, but still happens.

	Disabling ntpd helps to not "trigger" the problem often. With
ntpd enabled the problem happens at least once a day. Without ntpd, it
doesn't happen anymore or seldom happens. Disabling high resolution
timers helps too.

	I'll follow your previous suggestions, but I didn't have time
yet. If anyone needs more info, just ask. Thanks.

	Ps: just to clarify for Thomas. The problem has started in
2.6.25 kernel and remain in 2.6.26 until now (2.6.27-rc8). Something
(probably related to timers) changed in 2.6.25 which causes this,
although the effect is seem on network stalling.


--=20
