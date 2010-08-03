From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] e1000e: update to workaround for
 jumbo frames on 82577
Date: Mon, 02 Aug 2010 21:21:24 -0700 (PDT)
Message-ID: <20100802.212124.108786377.davem@davemloft.net>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
	<20100803002748.4179.85660.stgit@localhost.localdomain>
	<AANLkTi=TvRmXxJu1+y9B8x7G55Ur9wNhYzDZ8Q=+HJRJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60614
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754155Ab0HCEVG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 00:21:06 -0400
In-Reply-To: <AANLkTi=TvRmXxJu1+y9B8x7G55Ur9wNhYzDZ8Q=+HJRJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 2 Aug 2010 17:36:56 -0700

> On Mon, Aug 2, 2010 at 17:27, Jeff Kirsher <jeffrey.t.kirsher@intel.c=
om> wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> For OEM systems with this part that also has Spread Spectrum Clockin=
g (SSC)
>> enabled in the BIOS, there is an Rx performance issue with 4K jumbo =
frames.
>> Leaving the defaults in PHY page 770 register 26 resolves the issue,=
 and
>> does not negatively impact jumbo frames on systems with SSC disabled=
=2E
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>> =A0drivers/net/e1000e/netdev.c | =A0 =A05 -----
>> =A01 files changed, 0 insertions(+), 5 deletions(-)
>>
>=20
> Please disregard this patch, it was sent out accidentally (my bad).
> During testing issues were found and changes need to be made to this
> patch.

Ok.
