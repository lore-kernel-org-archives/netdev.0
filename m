From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPv6] Add ifindex field in ND user option messages
Date: Mon, 12 Nov 2007 16:56:56 -0800 (PST)
Message-ID: <20071112.165656.149058082.davem@davemloft.net>
References: <20071113005413.GA1767@via.ecp.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	rdenis@simphalempin.com
To: linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753195AbXKMA46 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 19:56:58 -0500
In-Reply-To: <20071113005413.GA1767@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pierre Ynard <linkfanel@yahoo.fr>
Date: Tue, 13 Nov 2007 01:54:13 +0100

> Userland neighbor discovery options are typically heavily involved wi=
th
> the interface on which thay are received: add a missing ifindex field=
 to
> the original struct. Thanks to R=E9mi Denis-Courmont.
>=20
> Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>

Unfortunately you cannot change the layout of a structure
already exported to userspace, it is part of the ABI.

You'll need to create a new netlink attribute or similar
in order to provide this information.
