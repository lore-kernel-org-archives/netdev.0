From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH 2.4.22-bk] dev->promiscuity refcounting broken in
Date: Wed, 2 Jul 2003 09:17:22 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307020517.JAA05258@dub.inr.ac.ru>
References: <20030701.155051.104064679.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com, lunz@falooley.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030701.155051.104064679.davem@redhat.com> from "David S. Miller" at Jul 01, 2003 03:50:51 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I can't see any reason to be mucking about with the device promiscuity
> on NETDEV_DOWN and NETDEV_UP events in the first place.

I do not remember why protocols (i.e. IP) withdraw multicast lists
on device down too. :-)

>							 The attached
> patch seems to fix all the cases I can think of.

I think it is right.

Actually, if to follow the tradition, we could do the same thing as IP does
(remembering that mc record is not loaded), but it looks really useless.

Dave, the patch looks OK.

Alexey



PS. Wow!

X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id h61MHp2x016322
X-MIME-Autoconverted: from quoted-printable to 8bit by devserv.devel.redhat.com id h61MI0K27113
Mime-Version: 1.0 (modified by Mew)
Content-Transfer-Encoding: quoted-printable (modified by Mew)

All three agents (oss, redhat and your mailer) are damn smart. Rare mail
will pass through this uncorrupted, I guess. :-)
