From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 4/3] rcu: documents rculist_nulls
Date: Fri, 14 Nov 2008 16:16:38 +0100
Message-ID: <1226675798.7685.7797.camel@twins>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>
	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>
		 <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com>
	 <1226582997.7685.4786.camel@twins> <491C2F27.2000908@cosmosbay.com>
	  <491C4FA8.4020704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Corey Minyard <minyard@acm.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:11146 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbYKNPca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 10:32:30 -0500
In-Reply-To: <491C4FA8.4020704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 17:02 +0100, Eric Dumazet wrote:
>=20
Eric Dumazet a =C3=A9crit :
> > Peter Zijlstra a =C3=A9crit :
> >> So by not using some memory barriers (would be nice to have it
> >> illustrated which ones), we can race and end up on the wrong chain=
, in
> >> case that happens we detect this by using this per-chain terminato=
r and
> >> try again.
> >>
> >> It would be really good to have it explained in the rculist_nulls.=
h
> >> comments what memory barriers are missing, what races they open, a=
nd how
> >> the this special terminator trick closes that race.
> >=20
> > OK, maybe I should add a Documentation/RCU/rculist_nulls.txt file w=
ith
> > appropriate examples and documentation.
> >=20
> > (Say the lookup/insert algorithms, with standard hlist and memory b=
arriers,
> > and with hlist_nulls without those two memory barriers.
> >=20
>=20
> [PATCH 4/3] rcu: documents rculist_nulls
>=20
> Adds Documentation/RCU/rculist_nulls.txt file to describe how 'nulls'
> end-of-list can help in some RCU algos.
>=20
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

