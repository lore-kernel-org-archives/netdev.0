From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Mon, 07 Jan 2013 14:58:36 +0800
Message-ID: <50EA721C.8060806@asianux.com>
References: <50E82D7D.4090107@asianux.com>  <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>  <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>  <50EA6612.6010506@asianux.com> <1357540670.21481.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357540670.21481.38.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8807=E6=97=A5 14:37, Joe Perches =E5=86=
=99=E9=81=93:
> You did fine except you unnecessarily quoted the entire original emai=
l.
> Remember to trim your replies please.  _lots_ of people read these
> mailing lists and unnecessary quoting wastes all of their times.
>=20
  ok, thank you.

  I should notice, next time.  :-)

>> >   at least for me:
>> >     although it is good idea to add common, widely used features i=
n public tools function.
> It's akin to most of the minor uuid/bluetooth mac, etc codes

  after see the comments for function pointer in lib/vsprintf.c
  sorry for I do not think it is suitable to add ssid in vsprintf
    all formate features in vsprintf are face to kernel wide, not for o=
ne sub system
      one exception is for mac and ip:
        they have already been well known in kernel wide
        every one knows about mac and ip.
    I feel, our ssid is not quite well known in kernel wide

  maybe current place (net/wireless/) is not quite suitable for print_s=
sid:
    for bluetooth, it is not belong to net/wireless.
    if necessary, I suggest to reconstruct it within net sub system wid=
e, not in kernel wide.


  (it is also my fault for my original reply, it is not quite clear)


  Regards

--=20
Chen Gang

Asianux Corporation
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
