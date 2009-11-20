From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] p54: software hot-swap eeprom image
Date: Fri, 20 Nov 2009 12:32:00 -0800
Message-ID: <43e72e890911201232m1e0d573cq74f40580296ca81d@mail.gmail.com>
References: <200911202027.13284.chunkeey@googlemail.com> <1258746786.26965.83.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1258746786.26965.83.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2009 at 11:53 AM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, 2009-11-20 at 20:27 +0100, Christian Lamparter wrote:
>> This (aggregated) patch adds a new sysfs file "eeprom_overwrite"
>> which can be used to upload an customized eeprom image to the
>> driver during normal operation.
>>
>> The old wlanX device will quickly vanish. And if the new EEPROM
>> image passes all sanity checks the device will reappear.
>>
>> Hopefully, this proves to be an adequate solution for everyone
>> with a bad/missing EEPROM data/chip.
>
> Honestly I wonder if this would be better done with ethtool. =C2=A0Th=
ere's
> already ethtool --eeprom-dump, would it be so hard to do an ethtool
> --eeprom-load ?
>
> I can see a number of devices doing this, so in my mind it makes sens=
e
> to have a generic facility for this sort of thing. =C2=A0But then aga=
in it's
> not so common an operation and its fraught with danger :) =C2=A0Liber=
tas
> could potentially use this, but libertas has *two* EEPROM images that=
 it
> might need to update. =C2=A0So if ethtool did grow --eeprom-load we m=
ay want
> to account for more than one eeprom image.
>
> What do people think?

Can't request_firmware() be generalized for this sort of stuff too?

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
