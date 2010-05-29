From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: unlock on error path in cfserl_receive()
Date: Sat, 29 May 2010 00:19:24 -0700 (PDT)
Message-ID: <20100529.001924.214235371.davem@davemloft.net>
References: <20100526151648.GA15439@bicker>
	<AANLkTimYIjrnOwzSyALY42fhNojwh1zawaFMUVC1ml6Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, sjur.brandeland@stericsson.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: sjurbren@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751806Ab0E2HTO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 03:19:14 -0400
In-Reply-To: <AANLkTimYIjrnOwzSyALY42fhNojwh1zawaFMUVC1ml6Y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Wed, 26 May 2010 20:18:36 +0200

> Hi Dan.
>=20
> Dan Carpenter <error27@gmail.com> wrote:
>> There was an spin_unlock missing on the error path. =A0The spin_lock=
 was
>> tucked in with the declarations so it was hard to spot. =A0I added a=
 new
>> line.
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Acked-by: Sjur Braendeland

Applied.

Sjur, in the future please provide your full email address in
Acked-by: lines just as you would for a Signed-off-by: tag.

I fixed it up this time.

Thanks.
