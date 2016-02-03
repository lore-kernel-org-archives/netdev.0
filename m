From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: ibss.c backtrace when batman-adv adds wireless interface
Date: Wed, 03 Feb 2016 16:41:30 +0100
Message-ID: <1454514090.3083.8.camel@sipsolutions.net>
References: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw@mail.gmail.com>
	 <CA+5PVA55MSh-kKCLGcUV2uMkx+SqwuXY0WbONS8Q0mxh4+_gcw@mail.gmail.com>
	 (sfid-20160203_162659_997136_8B4E5DC7)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, b.a.t.m.a.n@lists.open-mesh.org
To: Josh Boyer <jwboyer@fedoraproject.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Kalle Valo <kvalo@codeaurora.org>,
	Simon Wunderlich <sw@simonwunderlich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39098 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172AbcBCPll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 10:41:41 -0500
In-Reply-To: <CA+5PVA55MSh-kKCLGcUV2uMkx+SqwuXY0WbONS8Q0mxh4+_gcw@mail.gmail.com> (sfid-20160203_162659_997136_8B4E5DC7)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-03 at 10:26 -0500, Josh Boyer wrote:
> On Wed, Feb 3, 2016 at 10:24 AM, Josh Boyer <jwboyer@fedoraproject.or
> g> wrote:
> > Hi All,
> >=20
> > We've had a user report the backtrace below when loading batman-adv=
=20
> > on
> > his machine.=C2=A0=C2=A0It looks like the cfg80211 layer is complai=
ning about
> > a
> > null bss returned, but I cannot tell if the rtlwifi driver or
> > batman-adv is in error here.
> >=20
> > Thoughts?
>=20
> Sorry, forgot to include the link to the actual bug report:
>=20
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1304428
>=20
> Reporter says this is new with 4.3.y and did not happen on e.g.
> 4.2.8.
>=20

AFAICT this should be a driver (or perhaps mac80211) issue, but I don't
see any information about the driver used.

johannes
