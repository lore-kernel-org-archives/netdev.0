From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Restrict "level use" for IPComp
 configuration
Date: Tue, 10 Dec 2013 14:11:58 +0100
Message-ID: <20131210131158.GM31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-4-git-send-email-fan.du@windriver.com>
 <20131209103856.GL31491@secunet.com>
 <52A67EF7.3070402@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42390 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401Ab3LJNMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 08:12:01 -0500
Content-Disposition: inline
In-Reply-To: <52A67EF7.3070402@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 10:39:51AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 18:38, Steffen Klassert wrote:
> >
> >I think this will make a lot of people unhappy. It was never require=
d
> >to set 'optional' for ipcomp, and I'd bet that most users don't set
> >it for ipcomp. I understand the problem, but we can't fix it like th=
at.
>=20
> Instead of making this check, what about wire 'optional' to 1? it doe=
sn't
> breaking existing script.

But it might change what a user expects to happen.

>=20
> Do you have any other way to cure this problem other than 'optional'.
>=20

I think the user can 'fix' the problem himself by setting 'optional'.
This has also the advantage that he is aware about the change. Maybe
this should be documented somewhere.
