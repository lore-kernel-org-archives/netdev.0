From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 16:33:28 +0200
Message-ID: <20060818143328.GC6393@wohnheim.fh-wedel.de>
References: <200608181331.19501.ossthema@de.ibm.com> <1155903451.4494.168.camel@laptopd505.fenrus.org> <44E5BFB7.4000400@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arjan van de Ven <arjan@infradead.org>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:6294 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S932458AbWHROdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:33:37 -0400
To: Thomas Klein <osstklei@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44E5BFB7.4000400@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 August 2006 15:25:11 +0200, Thomas Klein wrote:
> Arjan van de Ven wrote:
> >>+	queue->queue_length =3D nr_of_pages * pagesize;
> >>+	queue->queue_pages =3D vmalloc(nr_of_pages * sizeof(void *));
> >
> >
> >wow... is this really so large that it warrants a vmalloc()???
>=20
> Agreed: Replaced with kmalloc()

kzalloc() and you can remove the memset() as well.

J=F6rn

--=20
Data dominates. If you've chosen the right data structures and organize=
d
things well, the algorithms will almost always be self-evident. Data
structures, not algorithms, are central to programming.
-- Rob Pike
