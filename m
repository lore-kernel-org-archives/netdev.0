From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 13:02:10 +0200
Message-ID: <1176202930.8459.81.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>
	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>
	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qGiRBc3ZF7DnfbaQEgyO"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48410 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbXDJLBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 07:01:41 -0400
In-Reply-To: <461B6B22.3090009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qGiRBc3ZF7DnfbaQEgyO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 12:46 +0200, Patrick McHardy wrote:

> Not totally different, so far I think we should use the same attributes
> as for RTM_SETLINK messages and include the device-specific stuff in
> IFLA_PROTINFO, which is symetric to what the kernel sends in RTM_NETLINK
> messages (see br_netlink.c for an example). The easiest case would be an
> empty IFLA_PROTINFO attribute, which would simply create a device
> without any configuration.

I'll have to look up these things.

> The main advantage that we don't get more weird sysfs/proc/ioctl based
> interfaces

Please don't put me into a corner I don't want to be in ;) The new
wireless stuff was completely designed using netlink. The sysfs
interface to these two specific things was a concession since it used to
exist before and we don't really have a fully functional userspace tool
yet.

>  and use the same interface that is used for all other network
> configuration, which f.e. will allow to add support for all software
> devices to iproute without much effort, so you don't need 30 different
> tools for configuring the different software device types anymore.
> Additionally we get atomic setup/dumps and extensibility.

I don't think wireless can get away without a new tool. So much stuff
there. Look at
http://git.kernel.org/?p=3Dlinux/kernel/git/linville/wireless-dev.git;a=3Db=
lob;f=3Dinclude/linux/nl80211.h;hb=3DHEAD

johannes

--=-qGiRBc3ZF7DnfbaQEgyO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGG26y/ETPhpq3jKURAlhFAJ9ulLLLtpIguDkRT2y45bhZ54GVygCdGe3g
a6WyJMVQxAYld+xFWvPl8M8=
=iYok
-----END PGP SIGNATURE-----

--=-qGiRBc3ZF7DnfbaQEgyO--

