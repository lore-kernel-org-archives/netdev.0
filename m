From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] NFC: trf7970a: add device tree option for 27MHz clock
Date: Mon, 19 Dec 2016 18:23:00 -0500
Message-ID: <CAO7Z3WKmEbJCN_=srxTVKXvtz84vHGi41RS+9T7fmkmhRB6nEw@mail.gmail.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com> <20161219223111.itu77g7wsqtj6cvs@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>,
        Justin Bronder <justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161219223111.itu77g7wsqtj6cvs@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I can make that change, however, I worry that it may be a bit
misleading, since there are only two supported clock frequencies, but
a number like that to me implies that it could be set to any number
you want.   I'm new at this, and so I'll go ahead and change it as you
request, but I'd like to hear your thoughts on my concern.

Thanks
Geoff
Geoff Lansberry


Engineering Guy
Kuv=C3=A9e, Inc
125 Kingston St., 3rd Floor
Boston, MA 02111
1-617-290-1118 (m)
geoff.lansberry (skype)
http://www.kuvee.com



On Mon, Dec 19, 2016 at 5:31 PM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Thu, Dec 15, 2016 at 05:30:42PM -0500, Geoff Lansberry wrote:
>> From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
>>
>> ---
>>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  3 ++
>>  drivers/nfc/trf7970a.c                             | 42 +++++++++++++++=
+------
>>  2 files changed, 34 insertions(+), 11 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Do=
cumentation/devicetree/bindings/net/nfc/trf7970a.txt
>> index 32b35a0..9dda879 100644
>> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
>> @@ -21,6 +21,8 @@ Optional SoC Specific Properties:
>>  - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
>>    where an extra byte is returned by Read Multiple Block commands issue=
d
>>    to Type 5 tags.
>> +- crystal_27mhz: Set to specify that the input frequency to the trf7970=
a is 27.12MHz
>> +
>
> Can't you use 'clock-frequency =3D "27000000";'?
>
>>
>>  Example (for ARM-based BeagleBone with TRF7970A on SPI1):
>>
>> @@ -43,6 +45,7 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI=
1):
>>               irq-status-read-quirk;
>>               en2-rf-quirk;
>>               t5t-rmb-extra-byte-quirk;
>> +             crystal_27mhz;
>>               status =3D "okay";
>>       };
>>  };
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
