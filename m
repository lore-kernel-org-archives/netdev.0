From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] team: implement carrier change
Date: Sun, 30 Dec 2012 14:06:50 +0100
Message-ID: <A40E06F5-7F2F-454F-9C2D-A023CCB30D43@resnulli.us>
References: <1356831061-1483-1-git-send-email-fbl@redhat.com> <CAHXqBFKtm6y3V-OepX9NnDP1GT28J=tPRmEtmR68wACPT9Pq8g@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Flavio Leitner <fbl@redhat.com>
To: =?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:53058 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab2L3NG6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 08:06:58 -0500
Received: by mail-ee0-f51.google.com with SMTP id d4so5715444eek.24
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 05:06:57 -0800 (PST)
In-Reply-To: <CAHXqBFKtm6y3V-OepX9NnDP1GT28J=tPRmEtmR68wACPT9Pq8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



30. 12. 2012 v 14:03, Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:

> 2012/12/30 Flavio Leitner <fbl@redhat.com>:
>> The user space teamd daemon may need to control the
>> master's carrier state depending on the selected mode.
> [...]
>> +static int team_change_carrier(struct net_device *dev, bool new_car=
rier)
>> +{
>> +       if (new_carrier)
>> +               netif_carrier_on(dev);
>> +       else
>> +               netif_carrier_off(dev);
>> +       return 0;
>> +}
>> +
> [...]
>> +       .ndo_change_carrier     =3D team_change_carrier,
>=20
> I wonder what else you might put in the .ndo_change_carrier
> implementation? It's already the same for dummy device and tunnels
> would get more copies. Maybe it would be enough to allocate a bit in
> netdev->priv_flags and use that in dev_change_carrier() instead?
> =20

=46lavio has a patch adding some more code here prepared already. Will =
be posted soon.

> Best Regards,
> Micha=C5=82 Miros=C5=82aw
