From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 6 Apr 2011 14:08:01 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1104061400320.6556@JBRANDEB-DESK2.amr.corp.intel.com>
References: <20110406195719.GE14697@ghostprotocols.net>  <20110406.130239.232756965.davem@davemloft.net>  <1302121136.2701.16.camel@edumazet-laptop>  <20110406.132906.200378990.davem@davemloft.net> <1302121945.2701.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"acme@ghostprotocols.net" <acme@ghostprotocols.net>,
	"jesse.brandeburg@gmail.com" <jesse.brandeburg@gmail.com>,
	"fedora-kernel-list@redhat.com" <fedora-kernel-list@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35213 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab1DFVIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 17:08:18 -0400
In-Reply-To: <1302121945.2701.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 6 Apr 2011, Eric Dumazet wrote:

> Le mercredi 06 avril 2011 =C3=A0 13:29 -0700, David Miller a =C3=A9cr=
it :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 06 Apr 2011 22:18:56 +0200
> >=20
> > > I remember last time I work on a fedora kernel, it had conntrack =
enabled
> > >=20
> > > And yes, conntrack can really slowdown a router, because of defau=
lt
> > > parameters.
> >=20
> > Yes, if conntrack is enabled performance will indeed tank.
>=20
> I just check on latest fedora14 (yum updated) :
>=20
> - conntrack is statically included in kernel, you cannot remove it.
>=20
>=20
> Hmm...

Thanks for the replies,=20
Yes indeed, I bet that conntrack was the item that caused the grief I s=
aw. =20
In fact turning off CONFIG_NETFILTER disables conntrack and solved my=20
problem. :-)

Now the question is how to get the netfiltery/conntracky goodness witho=
ut=20
impacting those who want to go fast, maybe without a helmet.
