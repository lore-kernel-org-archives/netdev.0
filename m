From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/2] sctp: convert hash list to RCU
Date: Fri, 19 Feb 2010 09:41:09 +0100
Message-ID: <1266568869.3136.0.camel@edumazet-laptop>
References: <20100219055520.223027612@vyatta.com>
	 <20100219055628.436258223@vyatta.com>
	 <1266567229.2877.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:58525 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab0BSIlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 03:41:16 -0500
In-Reply-To: <1266567229.2877.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 09:13 +0100, Eric Dumazet a =C3=
=A9crit :
> Le jeudi 18 f=C3=A9vrier 2010 =C3=A0 21:55 -0800, Stephen Hemminger a=
 =C3=A9crit :
> > pi=C3=A8ce jointe document texte brut (sctp-rcu.patch)
> > This patch converts existing SCTP hash list to using RCU
> > rather than reader/writer lock. Also, get rid of no longer used
> > locking wrappers.
> >=20
> > In future, the SCTP hash locking should be broken out from the
> > hash structure because of the wasted space for the hash locks
> > and associated holes. A single lock per hashlist is sufficient
> > now that RCU is used.
> >=20
> > Compile tested only. I can't think of an SCTP stress application.
> >=20
> > P.s: Some janitor ought to go through and remove the locking
> > macros here.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
>=20
> Stephen, I read full patch and cannot see how you respect the rcu gra=
ce
> period at dismantle phase. I am not familiar with SCTP, maybe its
> already done ? (before the patch)
>=20

OOps sorry, I finaly saw the light, please ignore this comment.


