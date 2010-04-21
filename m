From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Tue, 20 Apr 2010 18:06:46 -0700 (PDT)
Message-ID: <20100420.180646.216759318.davem@davemloft.net>
References: <m2ged82fe3e1004191408p53f19073x106ef56677c8a5df@mail.gmail.com>
	<DD217C72-156B-403D-B83B-EB365C782F2B@kernel.crashing.org>
	<o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: galak@kernel.crashing.org, afleming@freescale.com,
	netdev@vger.kernel.org
To: timur.tabi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58516
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754517Ab0DUBGl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 21:06:41 -0400
In-Reply-To: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timur Tabi <timur.tabi@gmail.com>
Date: Tue, 20 Apr 2010 10:01:48 -0500

> On Mon, Apr 19, 2010 at 11:43 PM, Kumar Gala <galak@kernel.crashing.o=
rg> wrote:
>=20
>> spin_event_timeout doesn't make sense for this. =A0The patch is fine=
=2E
>=20
> Can you please elaborate on that?  I don't understand why you think
> that.  spin_event_timeout() takes an expression and a timeout, and
> loops over the expression calling cpu_relax(), just like this loop
> does.

Indeed it does, Kumar this request seems reasonable.
