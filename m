From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: checking the wrong variable
Date: Sat, 15 Jan 2011 21:05:17 -0800 (PST)
Message-ID: <20110115.210517.112602810.davem@davemloft.net>
References: <20110115130639.GA2721@bicker>
	<AANLkTimyZQ1BEJ=tPK4LrYWhQaGd+xhYUsVEENibEVoU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: sjurbren@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734Ab1APFEo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jan 2011 00:04:44 -0500
In-Reply-To: <AANLkTimyZQ1BEJ=tPK4LrYWhQaGd+xhYUsVEENibEVoU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjurbren@gmail.com>
Date: Sat, 15 Jan 2011 15:03:31 +0100

>> In the original code we check if (servl =3D=3D NULL) twice. =A0The f=
irst time
>> should print the message that cfmuxl_remove_uplayer() failed and set
>> "ret" correctly, but instead it just returns success. =A0The second =
check
>> should be checking the value of "ret" instead of "servl".
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> Thank you for spotting and correcting this.
> Looks good to me (reviewed only)
>=20
> Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied, thanks.
