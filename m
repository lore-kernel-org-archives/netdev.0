From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec workshop at netdev01?
Date: Mon, 26 Jan 2015 10:11:10 +0100
Message-ID: <20150126091109.GK13046@secunet.com>
References: <20150106101936.GC31458@secunet.com>
 <54AF677E.9080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"Du, Fan" <fan.du@intel.com>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36764 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbbAZJLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 04:11:20 -0500
Content-Disposition: inline
In-Reply-To: <54AF677E.9080108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 01:30:38PM +0800, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B401=E6=9C=8806=E6=97=A5 18:19, Steffen Klassert=
 =E5=86=99=E9=81=93:
> >
> >- We still lack a 32/64 bit compatibiltiy layer for IPsec, this issu=
e
> >   comes up from time to time. Some solutions were proposed in the p=
ast
> >   but all had problems. The current behaviour is broken if someone =
tries
> >   to configure IPsec with 32 bit tools on a 64 bit machine. Can we =
get
> >   this right somehow or is it better to just return an error in thi=
s case?
>=20
> Before a clean solution show up, I think it's better to warn user in =
some way
> like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many p=
eople
> who stuck there will always spend time and try to fix this issue in w=
hatever way.

Yes, this is the first thing we should do. I'm willing to accept a patc=
h :)

>=20
> >- Changing the system time can lead to unexpected SA lifetime change=
s. The
> >   discussion on the list did not lead to a conclusion on how to fix=
 this.
> >   What is the best way to get this fixed?
>=20
> I rise this issue long ago before, the culprit is SA lifetime is mark=
ed by wall clock.
> In a reasonable way it should be marked as monotonic boot time(counti=
ng suspend time
> as well). Then every thing will be work correctly. I have such a patc=
h works correctly.
> EXCEPT: SA migration, where SA lifetime comes from outside.
> I didn't look at SA migration part though, so any comments? Steffen

I have not looked into this for longer. So I can not comment on it
now, but I could be prepared for discussion on netdev01.
