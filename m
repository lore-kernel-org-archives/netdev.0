From: Bastian Bittorf <bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Wed, 20 Feb 2013 09:15:38 +0100
Message-ID: <20130220081538.GO8730@medion.lan>
References: <20130219.005206.397289032011003833.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com>
 <5123BCFF.5090408@lwfinger.net>
 <20130219.131553.787630407148880340.davem@davemloft.net>
 <5123C43D.2020602@lwfinger.net>
 <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com>
 <512437FA.2030105@lwfinger.net>
 <CA+XFjipJHGTvzUx6yy1DTc74kbrPEQxM08zW=N1uf43=Q6pwdg@mail.gmail.com>
 <5124782D.3050803@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-15?Q?G=E1bor?= Stefanik <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, openwrt-devel-ZwoEplunGu0+xA9t4nZiwti2O/JbrIOy@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5124782D.3050803-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> [20.02.2013 08:32]:
> On 02/20/2013 12:26 AM, G=E1bor Stefanik wrote:
> >
> >Is this an issue that vendor drivers are also vulnerable to? If it i=
s
> >a firmware issue, I would certainly think so.
>=20
> I also think so, at least if they are using the firmware version that
> Bastian is using. His logs don't have that info in them, but I
> certainly saw the problem on my BCM4312 using firmware 508.154 from
> 2009.
=20
Another test this morning with heavy downloading (but tcp only)
show slot usage auf max 204/256. we are using firmware

"version 666.2 (2011-02-23 01:15:07)" which is OpenWrt's default
for b43. see here the full logs, including minstrel output and dmesg:

http://intercity-vpn.de/files/openwrt/b43test2.dmesg.txt

if a slot needs ~2500 bytes, so 256 slot are only 640kb which seems
ok to me. ofcourse it raises the memory consumption by 500kb, but now
the router is useful 8-)

thank you! bye, bastian

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
