From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 9 Feb 2015 15:30:02 +0100
Message-ID: <CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
References: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
	<87a90nqp45.fsf@nemi.mork.no>
	<CAKfDRXhW-izhes0qq2qJA0ojm37Eg=dybYSdzo8u-VzhT15EGw@mail.gmail.com>
	<CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Aleksander Morgado <aleksander@aleksander.es>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:46723 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375AbbBIOaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 09:30:03 -0500
Received: by mail-yh0-f46.google.com with SMTP id z6so1529948yhz.5
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 06:30:02 -0800 (PST)
In-Reply-To: <8761bbqker.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 9, 2015 at 2:33 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> That is pretty old relative to this hardware. First commercial releas=
e?
> I don't really want to push you to do an upgrade, but it would sure b=
e
> nice to have this test repeated on a recent firmware version.  Not th=
at
> I can spot anything particularily promising in the release notes.

I updated firmware now, but still see the same behavior.

> I did find our previous discussions about these two RMNET1 and RMNET2
> functions, e.g:
> http://lists.freedesktop.org/archives/libqmi-devel/2014-July/000875.h=
tml
> and it seems to indicate that both work as long as you configure them
> for 802.3 framing. But that could just be an information feedback
> loop...

That is correct. In order for this device to accept network traffic
(or driver to accept packets from device), I have to set the transfer
mode to 802.3.

-Kristian
