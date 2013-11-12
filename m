From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Revert "sierra_net: keep status interrupt URB active"
Date: Tue, 12 Nov 2013 10:25:10 -0600
Message-ID: <1384273510.14773.0.camel@dcbw.foobar.com>
References: <1383310428-19913-1-git-send-email-bjorn@mork.no>
	 <1383596827.29469.1.camel@dcbw.foobar.com>
	 <1383938944.29096.7.camel@dcbw.foobar.com> <87txfm8vz5.fsf@nemi.mork.no>
	 <1383946173.29096.12.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Henderson <jhen-qw6QB7/foO7QT0dZR+AlfA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383946173.29096.12.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-08 at 15:29 -0600, Dan Williams wrote:
> On Fri, 2013-11-08 at 21:44 +0100, Bj=C3=B8rn Mork wrote:
> > Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > > On Mon, 2013-11-04 at 14:27 -0600, Dan Williams wrote:
> > >> On Fri, 2013-11-01 at 13:53 +0100, Bj=C3=B8rn Mork wrote:
> > >> > This reverts commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf.
> > >> >=20
> > >> > It's not easy to create a driver for all the various firmware
> > >> > bugs out there.
> > >> >=20
> > >> > This change caused regressions for a number of devices, which
> > >> > started to fail link detection and therefore became completely
> > >> > non-functional. The exact reason is yet unknown, it looks like
> > >> > the affected firmwares might actually need all or some of the
> > >> > additional SYNC messages the patch got rid of.
> > >> >=20
> > >> > Reverting is not optimal, as it will re-introduce the original
> > >> > problem, but it is currently the only alternative known to fix
> > >> > this issue.
> > >>=20
> > >> Instead, how does the following patch work for you?
> > >
> > > Bjorn, did you have a chance to try this patch out on your device=
s?
> >=20
> > The only DirectIP device I have is the MC7710, which never had any =
of
> > the firmware issues you are trying to fix. I only tried to forward =
Johns
> > issue.
> >=20
> > When this patch worked for John, then I am pretty confident that yo=
u
> > have solved the problem here.
>=20
> Well, "solved", since I still have no idea why the original patch wou=
ld
> cause the device behavior based on what I know and have read about th=
e
> expected firmware/host handshaking sequence.  But the patch there
> appears to fix the problem *and* not blindly send tons of SYNCs forev=
er.
>=20
> So I'll go ahead and submit a proper version of it.

Actually, is "[PATCH] usbnet: fix status interrupt urb handling" the
real fix for this problem?

John, any chance you could revert my RFC patch and try Felix's patch in
that mail?

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
