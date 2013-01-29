From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv4: introduce address lifetime
Date: Tue, 29 Jan 2013 14:00:33 -0500 (EST)
Message-ID: <20130129.140033.1738779666268159179.davem@davemloft.net>
References: <1359056501-6752-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	psimerda@redhat.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	nhorman@tuxdriver.com, dcbw@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab3A2TAf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:00:35 -0500
In-Reply-To: <1359056501-6752-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 24 Jan 2013 20:41:41 +0100

> There are some usecase when lifetime of ipv4 addresses might be helpf=
ul.
> For example:
> 1) initramfs networkmanager uses a DHCP daemon to learn network
> configuration parameters
> 2) initramfs networkmanager addresses, routes and DNS configuration
> 3) initramfs networkmanager is requested to stop
> 4) initramfs networkmanager stops all daemons including dhclient
> 5) there are addresses and routes configured but no daemon running. I=
f
> the system doesn't start networkmanager for some reason, addresses an=
d
> routes will be used forever, which violates RFC 2131.
>=20
> This patch is essentially a backport of ivp6 address lifetime mechani=
sm
> for ipv4 addresses.
>=20
> Current "ip" tool supports this without any patch (since it does not
> distinguish between ipv4 and ipv6 addresses in this perspective.
>=20
> Also, this should be back-compatible with all current netlink users.
>=20
> Reported-by: Pavel =A6imerda <psimerda@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Seems reasonable, applied, thanks.
