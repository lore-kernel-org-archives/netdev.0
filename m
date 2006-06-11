From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: Updated sysctl documentation take #2
Date: Sat, 10 Jun 2006 20:41:00 -0700
Message-ID: <20060610204100.901a0de1.rdunlap@xenotime.net>
References: <20060607205316.bbb3c379.diegocg@gmail.com>
	<20060607130653.9a4d572c.rdunlap@xenotime.net>
	<20060608001806.028ab05a.diegocg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, linux-xfs@oss.sgi.com, ecki@lina.inka.de,
	lkml@rtr.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:9118 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751046AbWFKDiQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 23:38:16 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 20:38:12 -0700
To: Diego Calleja <diegocg@gmail.com>
In-Reply-To: <20060608001806.028ab05a.diegocg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Jun 2006 00:18:06 +0200 Diego Calleja wrote:

> El Wed, 7 Jun 2006 13:06:53 -0700,
> "Randy.Dunlap" <rdunlap@xenotime.net> escribi=F3:
>=20
> > OK, that's all for the README file.  I'll look at the rest of it
> > sometime this week.  I don't think that it's quite ready to be merg=
ed.
>=20
> Thank's for your review, altought I didn't though someone was to revi=
ew
> so deeply a documentation patch ;) I've gone through all the files an=
d
> fixed the 72-col limit and everything I could. I've updated the patch
> http://terra.es/personal/diegocg/sysctl-docs

Here are some more comments for you.

1.  There are quite a few lines (17) ending with ^M (carriage return)
that should be removed.

2.  Lines like this one should end with a period (full stop):

+This file is SPARC-only

3.  I would put this comment near the top of each file, not at
the end:

+PLEASE KEEP THIS FILE ORDERED ALPHABETICALLY.


Other than that, it's looking good to me.

Thanks,
---
~Randy
