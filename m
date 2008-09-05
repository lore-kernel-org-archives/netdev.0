From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TCP stateless offload with bonding?
Date: Fri, 5 Sep 2008 17:38:29 +0100
Message-ID: <20080905163828.GK7908@solarflare.com>
References: <48C15885.9050908@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan =?iso-8859-1?B?Tm/p?= <dnoe@limebrokerage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:50402 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751792AbYIEQik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 12:38:40 -0400
Content-Disposition: inline
In-Reply-To: <48C15885.9050908@limebrokerage.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan No=E9 wrote:
> The Documentation/networking/bonding.txt file talks about VLAN offloa=
d=20
> support and the bonding driver, but not TCP segmentation, UDP/TCP=20
> checksum, etc, offloading.  Is this supported by the bonding driver, =
and=20
> if so, how is it configured?
>=20
> If it matters, we are using bonding for HA/failover, not for bandwidt=
h=20
> aggregation.

The bonding driver generally provides all the offload features that all=
 its
slave devices provide.  You can configure this by using ethtool on the =
slave
devices.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
