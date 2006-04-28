From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: IP1000 gigabit nic driver
Date: Fri, 28 Apr 2006 13:59:47 +0200
Message-ID: <200604281359.47321.netdev@axxeo.de>
References: <20060427142939.GA31473@fargo> <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com> <20060428113755.GA7419@fargo>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	David Vrabel <dvrabel@cantab.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:53993 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1030295AbWD1MAG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 08:00:06 -0400
To: David =?utf-8?q?G=C3=B3mez?= <david@pleyades.net>
In-Reply-To: <20060428113755.GA7419@fargo>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

David G=C3=B3mez wrote:
> On Apr 28 at 01:58:04, Pekka Enberg wrote:
> > Needs some serious coding style cleanup and conversion to proper 2.=
6
> > APIs for starters.
>=20
> Ok, i could take care of that, and it's a good way of getting my hand=
s
> dirty with kernel programming ;). David, if it's ok to you i'll do th=
e
> cleanup thing.

Have fun! Great that you do this.
=20
> What about 2.4/2.2 code? It's supposed to stay for compatibility
> or it should be removed before submitting?

Usually it should be removed.

The way to remove 2.4/2.2. code is by reimplementation
of 2.6-APIs in seperate files and headers and not submitting
these into latest kernel. Keep these somewhere else=20
(e.g. a project web site).

That way your drivers ALWAYS work with latest kernels
and you notice breakage of backward compatiblity quite easily.
If maintaining these parts becomes a pain with no gain,=20
you can simply stop providing these yourself.

"#ifdef KERNEL_VERSON" stuff in submitted drivers
is generally not acceptable. Since it is hard to test these parts.

I ported some off-tree drivers from 2.2 to 2.4. using this technique
and it works good, reduces maintainence burden and keeps
your driver current to latest APIs automatically.


Regards

Ingo Oeser
