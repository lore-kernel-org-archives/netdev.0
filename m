From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 13:00:35 +0200
Message-ID: <20060719110035.GA10081@wohnheim.fh-wedel.de>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718121517.GB28291@wohnheim.fh-wedel.de> <20060718190801.GA28540@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:15032 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S964797AbWGSLHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 07:07:03 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060718190801.GA28540@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 July 2006 23:08:01 +0400, Evgeniy Polyakov wrote:
> On Tue, Jul 18, 2006 at 02:15:17PM +0200, J?rn Engel (joern@wohnheim.=
fh-wedel.de) wrote:
> >=20
> > Your description makes it sound as if you would take a huge leap,
> > changing all in-kernel code _and_ the userspace interface in a sing=
le
> > patch.  Am I wrong?  Or am I right and would it make sense to extra=
ct
> > small incremental steps from your patch similar to those Van did in
> > his non-published work?
>=20
> My first implementation used existing kernel code and showed small
> performance win - there was binding of the socket to netchannel and a=
ll
> protocol processing was moved into process context.

Iirc, Van didn't show performance numbers but rather cpu utilization
numbers.  And those went down significantly without changing the
userspace interface.

Did you look at cpu utilization as well?  If you did and your numbers
are worse than Vans, he either did something smarter than you or
forged his numbers (quite unlikely).

J=F6rn

--=20
Sometimes, asking the right question is already the answer.
-- Unknown
