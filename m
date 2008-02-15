From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] Make sure sockets implement splice_read
Date: Fri, 15 Feb 2008 18:40:16 +0200
Message-ID: <200802151840.16824.rdenis@simphalempin.com>
References: <200802141853.35016.rdenis@simphalempin.com> <20080215.023601.219994317.davem@davemloft.net> <p73k5l6yygc.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:49394 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451AbYBOQko convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 11:40:44 -0500
In-Reply-To: <p73k5l6yygc.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Friday 15 February 2008 18:30:11 Andi Kleen, vous avez =E9crit=A0:
> David Miller <davem@davemloft.net> writes:
> > From: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
> > Date: Thu, 14 Feb 2008 18:53:34 +0200
> >
> >> Fixes a segmentation fault when trying to splice from a non-TCP so=
cket.
> >>
> >> Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
> >
> > Applied, thank you.
>
> That's also a stable candidate, isn't it?

Should go to 2.6.25-rc2, but the offending code is not in any stable re=
lease.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
