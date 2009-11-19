From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NET: Questions about supporting older kernel's with kmods
Date: Thu, 19 Nov 2009 14:53:13 +0000
Message-ID: <1258642393.2837.5.camel@achroite.uk.solarflarecom.com>
References: <4B055479.8070101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58850 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbZKSOxK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:53:10 -0500
In-Reply-To: <4B055479.8070101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-19 at 09:21 -0500, Gregory Haskins wrote:
> Hi All,
>=20
> So I was in the process of packaging up my venet driver so that it co=
uld
> not only support the in-tree build (in -next), but also build as a KM=
P
> for inclusion in existing distros that already shipped (like SLE, RHE=
L,
> CentOS, etc).
>=20
> The problem I ran into is that the ethtool and netdev_ops components =
of
> the in-tree version do not necessarily align with the substrate
> capabilities of older kernels.  What are the best-practices surroundi=
ng
> this issue?
>
> Q1) Is there any official CONFIG tags (e.g. HAVE_NETDEV_OPS) I can ke=
y
> off of,

These feature test macros are not consistently provided.

> or should I simply look at the kernel version?

That works up to a point, but the 'enterprise' distros backport a lot t=
o
earlier kernel versions which can make version tests invalid.

Some out-of-tree/backported drivers use autoconf-style tests, but there
is no standard way of doing this.

=EF=BB=BF[...]
> Q2) Is it considered "bad form" to include such compile-time directiv=
es
> in the version of the code going upstream?
[...]

Yes.  Don't do that.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

