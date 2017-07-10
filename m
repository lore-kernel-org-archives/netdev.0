From: Russell Joyce <russell.joyce@york.ac.uk>
Subject: Re: [PATCH] brcmfmac: added LED triggers for transmit/receive
Date: Mon, 10 Jul 2017 18:02:21 +0100
Message-ID: <B8983FA2-39CE-478B-80C9-F32E01856FE9@york.ac.uk>
References: <20170707140941.122115-1-russell.joyce@york.ac.uk>
 <CACna6rzY84oWNMBfP8N4A=Sxst_8b-S+rTbZFQV0yFcOR5MceQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Alan Millard <alan.millard@york.ac.uk>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Marcel Holtmann <marcel@holtmann.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        James Hughes <james.hughes@raspberrypi.org>,
        Tobias Klauser <tklauser@distanz.ch>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rzY84oWNMBfP8N4A=Sxst_8b-S+rTbZFQV0yFcOR5MceQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 1) I think most of it should be some cfg80211 shareable code.

I=E2=80=99m not sure exactly what you mean by this, could you please =
clarify?

> 2) This "rxtx" while surely present in other places sounds like a
> workaround for LED subsystem limitation. Maybe it's time to finally
> rework LED triggers.

I agree that it=E2=80=99s not an ideal way to do things, but I =
couldn=E2=80=99t think of a
better alternative. I think that having a combined trigger is useful =
though, for
situations like using the single LED on a Raspberry Pi to show Wi-Fi =
activity.


> On 10 Jul 2017, at 10:48, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> =
wrote:
>=20
> On 7 July 2017 at 16:09, Russell Joyce <russell.joyce@york.ac.uk> =
wrote:
>> Add three basic LED triggers to brcmfmac, based on those in mac80211: =
one
>> for transmit, one for receive, and one for combined transmit/receive.
>>=20
>> Signed-off-by: Russell Joyce <russell.joyce@york.ac.uk>
>=20
> 1) I think most of it should be some cfg80211 shareable code.
> 2) This "rxtx" while surely present in other places sounds like a
> workaround for LED subsystem limitation. Maybe it's time to finally
> rework LED triggers.
