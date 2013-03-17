From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable-3.8] net: cdc_ncm, cdc_mbim: allow user to
 prefer NCM for backwards compatibility
Date: Sun, 17 Mar 2013 12:00:00 -0400 (EDT)
Message-ID: <20130317.120000.2052121747248366215.davem@davemloft.net>
References: <1363259113-6909-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	gsuarez@smithmicro.com, alexey.orishko@stericsson.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab3CQQAC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:00:02 -0400
In-Reply-To: <1363259113-6909-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 14 Mar 2013 12:05:13 +0100

> commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible MBIM dev=
ices")
> introduced a new policy, preferring MBIM for dual NCM/MBIM functions =
if
> the cdc_mbim driver was enabled.  This caused a regression for users
> wanting to use NCM.
>=20
> Devices implementing NCM backwards compatibility according to section
> 3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a sing=
le
> USB function, using different altsettings.  The cdc_ncm and cdc_mbim
> drivers will both probe such functions, and must agree on a common
> policy for selecting either MBIM or NCM.  Until now, this policy has
> been set at build time based on CONFIG_USB_NET_CDC_MBIM.
>=20
> Use a module parameter to set the system policy at runtime, allowing =
the
> user to prefer NCM on systems with the cdc_mbim driver.
>=20
> Cc: Greg Suarez <gsuarez@smithmicro.com>
> Cc: Alexey Orishko <alexey.orishko@stericsson.com>
> Reported-by: Geir Haatveit <nospam@haatveit.nu>
> Reported-by: Tommi Kyntola <kynde@ts.ray.fi>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D54791
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Ok, this is fine as a solution for now, applied and queued up for -stab=
le.
