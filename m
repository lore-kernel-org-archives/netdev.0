From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Wed, 12 Jan 2011 18:48:12 +0100
Message-ID: <1294854492.3981.109.camel@edumazet-laptop>
References: <247288.34804.qm@web121705.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53143 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab1ALRsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 12:48:17 -0500
Received: by wyb28 with SMTP id 28so821720wyb.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 09:48:16 -0800 (PST)
In-Reply-To: <247288.34804.qm@web121705.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 09:42 -0800, Chris Rankin a =C3=A9cr=
it :
> --- On Wed, 12/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Apparently e100 driver uses GFP_ATOMIC allocations in setup
> > phase, and your machine doesnt have enough memory.
>=20
> Thanks. You'd think 64 MB of RAM would be enough... ;-).

I remember using linux on a 8MB machine a loooong time ago, but not a
2.6 kernel :)



