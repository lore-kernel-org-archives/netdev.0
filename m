From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] mac80211: silent build warnings
Date: Thu, 08 Jan 2015 08:41:47 +0100
Message-ID: <1420702907.2029.2.camel@sipsolutions.net>
References: <1420700655-9427-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420700655-9427-1-git-send-email-ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-01-08 at 15:04 +0800, Ying Xue wrote:
> Silent the following build warnings:
>=20
> net/mac80211/mlme.c: In function =E2=80=98ieee80211_rx_mgmt_beacon=E2=
=80=99:
> net/mac80211/mlme.c:1348:3: warning: =E2=80=98pwr_level_cisco=E2=80=99=
 may be used uninitialized in this function [-Wuninitialized]
> net/mac80211/mlme.c:1315:6: note: =E2=80=98pwr_level_cisco=E2=80=99 w=
as declared here

We seem to get this every year or so... just upgrade your compiler and
it will be smart enough to prove that it's wrong here.

I really *don't* want to shut up the compiler forcefully since it will
cause modern compilers to *not* warn if it actually *is* unused - and 0
is not a useful value - this code is tricky enough and we want compiler
help in case we need to modify it in the future.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
