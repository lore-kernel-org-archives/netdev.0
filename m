From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] cfg80211/nl80211: add wifi tx power mode switching
 support
Date: Tue, 28 Jun 2016 12:57:28 +0200
Message-ID: <1467111448.2493.15.camel@sipsolutions.net>
References: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
	<1462464478.23962.12.camel@redhat.com>
	<CABicQ-VWrRG+0rEEF0GxUTPixSbkA18Gq4b5hbgph60SoEQ+2Q@mail.gmail.com>
	<CABicQ-XWm=Rxdj3at4+-0OAWn=T7qOTWEaTK=JY7LDOmcN87yw@mail.gmail.com>
	<1462991620.22404.5.camel@redhat.com>
	 <CABicQ-UeU-8PPdK9Je51j_KD-BH8G1HuOjo0yZLcNBQgtJsyTA@mail.gmail.com>
	 (sfid-20160512_113439_036671_8A8ED376)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sameer Nanda <snanda-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Todd Broch <tbroch-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABicQ-UeU-8PPdK9Je51j_KD-BH8G1HuOjo0yZLcNBQgtJsyTA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20160512_113439_036671_8A8ED376)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-12 at 17:34 +0800, Wei-Ning Huang wrote:
>=C2=A0
> Johannes, I feel like being able to set calibration data at runtime
> is something common to all wireless drivers, so instead of using
> vendor commands what do you think if I pass the calibration data name
> instead of using those magic constants? This way, userspace does not
> need to know the details of what band/range power limit the driver
> supports. It allows for flexible driver side implementation and
> easier for userspace to control.
>=20

Sorry - I dropped this thread accidentally.

I'm not really sure I understand the situation fully, but right now to
me this seems very strange.

The physical antennas probably don't really change between "clamshell"
and "tablet" mode, do the physical radiation properties change enough
to actually require different *calibration*? To me, that sounds very
strange.

Assuming they don't really change fundamentally, then I understand the
need to set different power levels, per band/channel/whatever
granularity. But that can be achieved in very different ways, and in
fact if you look at Chrome then for our iwl7000 driver there we do have
a command to do something similar (currently a vendor command, but that
can be changed) without ever changing the *calibration*.

So to me, the whole premise of the patch is confusing and/or wrong.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
