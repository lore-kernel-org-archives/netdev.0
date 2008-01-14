From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 14:37:15 -0800
Message-ID: <20080114143715.69a5e9d1@deepthought>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
	<20080114125200.28cb4c69@deepthought>
	<20080114210105.GG9847@does.not.exist>
	<6101e8c40801141331n3cb66c04pc74ff07faf04c8fd@mail.gmail.com>
	<20080114213453.GJ9847@does.not.exist>
	<6101e8c40801141341hcb17b08h2fd5244bccb21928@mail.gmail.com>
	<20080114215209.GK9847@does.not.exist>
	<6101e8c40801141358la75d1c6vb100247dbbd651a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Adrian Bunk" <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: "Oliver Pinter (=?UTF-8?B?UGludMOpciBPbGl2w6ly?=)"
	<oliver.pntr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36818 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbYANWkK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 17:40:10 -0500
In-Reply-To: <6101e8c40801141358la75d1c6vb100247dbbd651a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 22:58:51 +0100
"Oliver Pinter (Pint=C3=A9r Oliv=C3=A9r)" <oliver.pntr@gmail.com> wrote=
:

> I "tested" other devices resources file, and only with skge freezed
> the system. from this think, that is skge driver bug
>=20

Its a property of the hardware, and the current device model has
no way to stop it.  Other devices are worse and can die if you access
pci config space.




--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
