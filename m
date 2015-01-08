From: Ying Xue <ying.xue-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH net-next] mac80211: silent build warnings
Date: Thu, 8 Jan 2015 15:45:12 +0800
Message-ID: <54AE3588.6040100@windriver.com>
References: <1420700655-9427-1-git-send-email-ying.xue@windriver.com> <1420702907.2029.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420702907.2029.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/08/2015 03:41 PM, Johannes Berg wrote:
> On Thu, 2015-01-08 at 15:04 +0800, Ying Xue wrote:
>> Silent the following build warnings:
>>
>> net/mac80211/mlme.c: In function =E2=80=98ieee80211_rx_mgmt_beacon=E2=
=80=99:
>> net/mac80211/mlme.c:1348:3: warning: =E2=80=98pwr_level_cisco=E2=80=99=
 may be used uninitialized in this function [-Wuninitialized]
>> net/mac80211/mlme.c:1315:6: note: =E2=80=98pwr_level_cisco=E2=80=99 =
was declared here
>=20
> We seem to get this every year or so... just upgrade your compiler an=
d
> it will be smart enough to prove that it's wrong here.
>=20
> I really *don't* want to shut up the compiler forcefully since it wil=
l
> cause modern compilers to *not* warn if it actually *is* unused - and=
 0
> is not a useful value - this code is tricky enough and we want compil=
er
> help in case we need to modify it in the future.
>=20

Thank for your explanation, and please ignore the noise.

Regards,
Ying

> johannes
>=20
>=20
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
