From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 16:32:14 +0100
Message-ID: <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	 <20111212150255.GA7506@kroah.com>
	 <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, adobriyan@gmail.com
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46614 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751026Ab1LLPcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 10:32:20 -0500
In-Reply-To: <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 d=C3=A9cembre 2011 =C3=A0 17:21 +0200, Daniel Baluta a =C3=A9=
crit :
> On Mon, Dec 12, 2011 at 5:02 PM, Greg KH <greg@kroah.com> wrote:
> > On Mon, Dec 12, 2011 at 02:44:52PM +0200, Daniel Baluta wrote:
> >> We can easily get kref refcount value by accesing
> >> kref->refcount but it is better to have a function
> >> for this.
> >
> > No, you should NEVER need the value of the kref, if you do, you are
> > doing something wrong.
> >
> > What code needs this patch?
>=20
> I plan to replace raw refcount patterns from net/ with kref, and
> I have noticed that there are some parts of code who need access
> to kref->refcount value.
>=20
> e.g:
>=20
> core/neighbour.c:152:			if (atomic_read(&n->refcnt) =3D=3D 1 &&
> core/neighbour.c:801:			if (atomic_read(&n->refcnt) =3D=3D 1 &&
> sched/cls_u32.c:459:	if (ht->refcnt =3D=3D 1) {
>=20

Well, its not a good idea.

kref adds nothing here.
