From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Mon, 18 Feb 2013 17:18:34 +0100
Message-ID: <CACna6rwLgE+o2mcRTemLFAqzdsEoA9Xyx8GyEQTh5qbv1iZ04A@mail.gmail.com>
References: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bastian Bittorf <bittorf-yxHw+vPQXZDZJqsBc5GL+g@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1361156480-32566-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2013/2/18 Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>:
> Bastian Bittorf reported that some of the silent freezes on a Linksys=
 WRT54G
> were due to overflow of the RX DMA ring buffer, which was created wit=
h 64
> slots. That finding reminded me that I was seeing similar crashed on =
a netbook,
> which also has a relatively slow processor. After increasing the numb=
er of
> slots to 128, runs on the netbook that previously failed now worked; =
however,
> I found that 109 slots had been used in one test. For that reason, th=
e number
> of slots is being increased to 256.

So probably ideal solution is to use 128 *and* fix the driver's
failing on overflow ;)

Did you try it on some old device? Just for sure firmware&DMA will
handle it correctly.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
