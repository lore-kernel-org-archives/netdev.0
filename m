From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 09 Feb 2015 14:19:47 -0800 (PST)
Message-ID: <20150209.141947.1972128292278697717.davem@redhat.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, aleksander@aleksander.es
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371AbbBIWUC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 17:20:02 -0500
In-Reply-To: <CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kristian Evensen <kristian.evensen@gmail.com>
Date: Mon, 9 Feb 2015 15:30:02 +0100

> On Mon, Feb 9, 2015 at 2:33 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>> That is pretty old relative to this hardware. First commercial relea=
se?
>> I don't really want to push you to do an upgrade, but it would sure =
be
>> nice to have this test repeated on a recent firmware version.  Not t=
hat
>> I can spot anything particularily promising in the release notes.
>=20
> I updated firmware now, but still see the same behavior.
>=20
>> I did find our previous discussions about these two RMNET1 and RMNET=
2
>> functions, e.g:
>> http://lists.freedesktop.org/archives/libqmi-devel/2014-July/000875.=
html
>> and it seems to indicate that both work as long as you configure the=
m
>> for 802.3 framing. But that could just be an information feedback
>> loop...
>=20
> That is correct. In order for this device to accept network traffic
> (or driver to accept packets from device), I have to set the transfer
> mode to 802.3.

So what are we going to do with this patch?
