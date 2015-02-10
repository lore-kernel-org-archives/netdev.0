From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 09:43:09 +0100
Message-ID: <CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@redhat.com>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:57347 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbbBJInK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 03:43:10 -0500
Received: by mail-oi0-f49.google.com with SMTP id v63so7469967oia.8
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 00:43:09 -0800 (PST)
In-Reply-To: <874mqucije.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 8:49 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>>> On Mon, Feb 9, 2015 at 2:33 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>>>> That is pretty old relative to this hardware. First commercial rel=
ease?
>>>> I don't really want to push you to do an upgrade, but it would sur=
e be
>>>> nice to have this test repeated on a recent firmware version.  Not=
 that
>>>> I can spot anything particularily promising in the release notes.
>>>
>>> I updated firmware now, but still see the same behavior.
>>>
>>>> I did find our previous discussions about these two RMNET1 and RMN=
ET2
>>>> functions, e.g:
>>>> http://lists.freedesktop.org/archives/libqmi-devel/2014-July/00087=
5.html
>>>> and it seems to indicate that both work as long as you configure t=
hem
>>>> for 802.3 framing. But that could just be an information feedback
>>>> loop...
>>>
>>> That is correct. In order for this device to accept network traffic
>>> (or driver to accept packets from device), I have to set the transf=
er
>>> mode to 802.3.
>>
>> So what are we going to do with this patch?
>
> I am hoping to get a second opinion from Aleksander.

I have a MC7304 and a MC7354 and both work with interfaces #8 and #10,
the only difference being that #10 ends up being raw-ip by default
instead of 802.3. I previously had old firmware in both, from early
last year IIRC, but last week I upgraded both to the latest firmware
available.

The only case in which I've seen such a modem (a MC7304) with 1 single
valid QMI interface (actually being #8) is when the modem is put in
"single-qmi" interface mode, which you can do forcing it to get the
MC7710 PID, e.g. AT!UDPID=3D68A2. But otherwise, if the modem was
exposed as 0x68c0, if#10 always worked for me...

--=20
Aleksander
https://aleksander.es
