From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] cdc_mbim workarounds for firmware bugs
Date: Sat, 02 Nov 2013 01:30:12 -0400 (EDT)
Message-ID: <20131102.013012.722023816896482451.davem@davemloft.net>
References: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexey.orishko@gmail.com,
	gsuarez@smithmicro.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3KBFaO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:30:14 -0400
In-Reply-To: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 31 Oct 2013 15:56:09 +0100

> The first patch is an attempt to work around a bug which prevents
> some devices from working with IPv6. I guess handling ND in a driver
> can be considered controversial, but it was the best alternative I
> came up with.
>=20
> The second is the "final solution" to the well known ZLP bug, which
> as we feared is present in a number of devices using different
> vendor IDs. Enabling this is definitely controversial, but I do not
> see any other possible solution.  The blacklist has become
> unmanagable, and I am pretty sure it is very incomplete due to
> under-reporting.  Devices known to work without ZLPs can be added
> to the whitelist.

This seems fine, both applied, thanks.
