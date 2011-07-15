From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: rx parser
Date: Fri, 15 Jul 2011 08:06:10 -0700 (PDT)
Message-ID: <20110715.080610.256697325487445331.davem@davemloft.net>
References: <1310728141.28792.10.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com,
	sandeep.kumar@freescale.com
To: sebastian.belden@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab1GOPGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:06:23 -0400
In-Reply-To: <1310728141.28792.10.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
Date: Fri, 15 Jul 2011 13:09:01 +0200

> +	struct gfar __iomem *regs =3D NULL;
> +	u32 tempval =3D 0;
> +=09
> +	regs =3D priv->gfargrp[0].regs;

There is no reason to initialize the variable 'regs' to NULL only to
initialize it to something else 2 lines later.

The initial 'tempval' initialization is also redundant, for the same
reason.
