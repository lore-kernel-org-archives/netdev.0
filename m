From: Tim Hartrick <tim@edgecast.com>
Subject: Re: crash in tcp_fragment
Date: Mon, 27 Feb 2012 16:29:52 -0700
Message-ID: <1330385392.7041.16.camel@boudreau>
References: <1330311465.2552.23.camel@boudreau>
	 <alpine.DEB.2.00.1202280115020.17924@melkinpaasi.cs.helsinki.fi>
Reply-To: tim@edgecast.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62619 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363Ab2B0XaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 18:30:07 -0500
Received: by mail-iy0-f174.google.com with SMTP id j37so409264iag.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 15:30:07 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1202280115020.17924@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ilpo,

Thanks for the answers.  This gives me some clarity on how to address
the problem.


Tim Hartrick

On Tue, 2012-02-28 at 01:18 +0200, Ilpo J=C3=A4rvinen wrote:
> On Sun, 26 Feb 2012, Tim Hartrick wrote:
>=20
> > 	We have been seeing the crash cited below on a number of our syste=
ms
> > running kernel version 2.6.34, 2.6.36 and 2.6.38 using a number of
> > different GigE controllers.  I note that commit
> > 2fceec13375e5d98ef033c6b0ee03943fc460950 introduced a band-aid for =
the
> > problem by replacing the BUG_ON() to a WARN().  I have two question=
s
> > related to this.
> >=20
> > 1) Is there a fix for the root cause?  Can I get a pointer to the c=
ommit
> > that claims to address the root cause?
>=20
> There have been multiple fixes recently on the counters which this co=
de=20
> depends on, however, nobody has afaict fully analyzed what else those=
=20
> fixed.
>=20
> > 2) Will disabling GSO/TSO make the problem go away?  That is, is
> > something related to GSO/TSO at the root of the problem?
>=20
> Very likely.
>=20
