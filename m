From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 14:15:17 +0200
Message-ID: <20060718121517.GB28291@wohnheim.fh-wedel.de>
References: <20060718081625.GA13830@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:30660 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S1751312AbWGRMP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 08:15:26 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060718081625.GA13830@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 July 2006 12:16:26 +0400, Evgeniy Polyakov wrote:
>=20
> Current tests with the latest netchannel patch show that netchannels=20
> outperforms sockets in any type of bulk transfer (big-sized, small-si=
zed,=20
> sending, receiving) over 1gb wire. I omit graphs and numbers here,=20
> since I posted it already several times. I also plan to proceed
> some negotiations which would allow to test netchannel support in 10g=
bit
> environment, but it can also happen after second development stage
> completed.

[ I don't have enough time for a deeper look.  So if my questions are
stupid, please just tell me so and don't take it personal. ]

After having seen Van Jacobson's presentation at LCA twice, it
appeared to me that Van could get astonishing speedups with small
incremental steps, only changing kernel code and leaving the
kernel-userspace interface as is.

Changing (or rather adding a new) the userspace interface was just the
last step, which also gave some performance benefits but is also a
change to the userspace interface and therefore easy to get wrong and
hard to fix later.

Your description makes it sound as if you would take a huge leap,
changing all in-kernel code _and_ the userspace interface in a single
patch.  Am I wrong?  Or am I right and would it make sense to extract
small incremental steps from your patch similar to those Van did in
his non-published work?

J=F6rn

--=20
When people work hard for you for a pat on the back, you've got
to give them that pat.
-- Robert Heinlein
