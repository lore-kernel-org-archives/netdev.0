From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] tcpv6: trivial formatting changes to
 send_(ack|reset)
Date: Thu, 09 Oct 2008 14:38:59 -0700 (PDT)
Message-ID: <20081009.143859.113768989.davem@davemloft.net>
References: <20081009.185230.46697834.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.64.0810091254160.1034@wrl-59.cs.helsinki.fi>
	<20081009141658.GB24905@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755827AbYJIVjX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 17:39:23 -0400
In-Reply-To: <20081009141658.GB24905@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 9 Oct 2008 11:16:58 -0300

> Em Thu, Oct 09, 2008 at 12:58:07PM +0300, Ilpo J=E4rvinen escreveu:
> > On Thu, 9 Oct 2008, YOSHIFUJI Hideaki / ???? wrote:
> > > I usually prefer sizeof(var) (or sizeof(*ptr)) over sizeof(type).
> > > Could you justify this change?
> >=20
> > My point was to make those two functions as equal as possible befor=
e merge=20
> > so that it's more easier to track what happens at the merge, both=20
> > versions pre-existed anyway. Sure I don't have much opinion either =
way.
>=20
> I agree with Yoshifuji, albeit it is unlikely that the type of that
> variable will change 8)

I agree as well and therefore left out the first hunk of this
patch when adding it to net-next-2.6
