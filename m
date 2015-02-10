From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 08:49:57 +0100
Message-ID: <874mqucije.fsf@nemi.mork.no>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kristian.evensen@gmail.com, netdev@vger.kernel.org,
	aleksander@aleksander.es
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36769 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbbBJHuV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 02:50:21 -0500
In-Reply-To: <20150209.141947.1972128292278697717.davem@redhat.com> (David
	Miller's message of "Mon, 09 Feb 2015 14:19:47 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@redhat.com> writes:
> From: Kristian Evensen <kristian.evensen@gmail.com>
> Date: Mon, 9 Feb 2015 15:30:02 +0100
>
>> On Mon, Feb 9, 2015 at 2:33 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>>> That is pretty old relative to this hardware. First commercial rele=
ase?
>>> I don't really want to push you to do an upgrade, but it would sure=
 be
>>> nice to have this test repeated on a recent firmware version.  Not =
that
>>> I can spot anything particularily promising in the release notes.
>>=20
>> I updated firmware now, but still see the same behavior.
>>=20
>>> I did find our previous discussions about these two RMNET1 and RMNE=
T2
>>> functions, e.g:
>>> http://lists.freedesktop.org/archives/libqmi-devel/2014-July/000875=
=2Ehtml
>>> and it seems to indicate that both work as long as you configure th=
em
>>> for 802.3 framing. But that could just be an information feedback
>>> loop...
>>=20
>> That is correct. In order for this device to accept network traffic
>> (or driver to accept packets from device), I have to set the transfe=
r
>> mode to 802.3.
>
> So what are we going to do with this patch?

I am hoping to get a second opinion from Aleksander.



Bj=C3=B8rn
