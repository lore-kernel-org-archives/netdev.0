From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion control algorithm
Date: Fri, 27 Oct 2006 17:21:58 +0200
Message-ID: <20061027152157.GB4632@c3po.0xdef.net>
References: <4540F076.70801@psc.edu> <20061026224407.GA2018@c3po.0xdef.net> <20061026235256.GB2018@c3po.0xdef.net> <20061026.170221.99202188.davem@davemloft.net> <20061027104311.GB3967@c3po.0xdef.net> <20061027074102.2a6fef4b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, jheffner@psc.edu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:64260 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1752298AbWJ0PV7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 11:21:59 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061027074102.2a6fef4b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger | 2006-10-27 07:41:02 [-0700]:

>Please no, it makes the socket option useless.

Technical no, in the sense of usability for everybody yes. You are righ=
t
Stephen, as a programmer I understand you complete!

But on the other side: We know for sure that this IS a problem if we al=
low
everybody to "prefer his socket".

In my opinion we should prefer fairness before usability! As John Heffn=
er
introduce, we can introduce a ranking system for congestion control alg=
orithms -
but this solution seems a little bit oversized and maybe can't be compl=
ete
guaranteed (complex interaction between the protocols in different
environment and so on, you know).

HGN




--=20
 /=B0\   --- JOIN NOW!!! ---=20
 \ /  ASCII ribbon campaign
  X       against HTML    =20
 / \    in mail and news  =20
