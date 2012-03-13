From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 00:25:00 -0700 (PDT)
Message-ID: <20120313.002500.1677522047432496866.davem@davemloft.net>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
	<20120312.225435.1585479447873313061.davem@davemloft.net>
	<CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759355Ab2CMHZC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 03:25:02 -0400
In-Reply-To: <CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Tue, 13 Mar 2012 00:21:55 -0700

> If I understand correctly, you're suggesting to go with
>=20
> return ((26468 >> (i+i)) & 3) - 1;
>=20
> correct?

Yes, at least for now.
