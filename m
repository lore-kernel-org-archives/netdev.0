From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] caif: cleanup: remove duplicate checks
Date: Mon, 31 May 2010 00:32:05 -0700 (PDT)
Message-ID: <20100531.003205.179958733.davem@davemloft.net>
References: <4BF8E6FE.9000303@bfs.de>
	<20100524162815.GA22515@bicker>
	<AANLkTilHv7m-oJSlXHJRLT9BLKscGLSFnGVCOB9U0kic@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, wharms@bfs.de, netdev@vger.kernel.org,
	sjur.brandeland@stericsson.com, sfr@canb.auug.org.au,
	kernel-janitors@vger.kernel.org
To: sjurbren@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756309Ab0EaHb4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 03:31:56 -0400
In-Reply-To: <AANLkTilHv7m-oJSlXHJRLT9BLKscGLSFnGVCOB9U0kic@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Mon, 24 May 2010 22:47:41 +0200

>  Dan Carpenter <error27@gmail.com> wrote:
>> "phyinfo" can never be null here because we assigned it an address, =
so I
>> removed both the assert and the second check inside the if statement=
=2E =A0I
>> removed the "phyinfo->phy_layer !=3D NULL" check as well because tha=
t was
>> asserted earlier.
>>
>> Walter Harms suggested I move the "phyinfo->phy_ref_count++;" outsid=
e
>> the if condition for readability, so I have done that.
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> Thanks, this looks good.

Applied.
