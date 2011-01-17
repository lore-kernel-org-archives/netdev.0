From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 12:13:01 +0100
Message-ID: <1295262781.3726.6.camel@jlt3.sipsolutions.net>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
	 (sfid-20110117_114654_053644_FFFFFFFF84F9C750)  <1295261783.24530.3.camel@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael =?ISO-8859-1?Q?B=FCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295261783.24530.3.camel@maggie>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-17 at 11:56 +0100, Michael B=C3=BCsch wrote:

> > As far as I can see, there are two possibilities:
> >=20
> > a) Merge the HND/AI code into the current SSB code, or
> >=20
> > b) add the missing code for SoCs to brcm80211 and replace the SSB c=
ode with it.
>=20
> Why can't we keep those two platforms separated?
> Is there really a lot of shared code between SSB and HND/AI?

I don't think there's a lot of shared code, but I believe that you need
b43 to be able to target cores on both? And b43 currently uses the SSB
APIs only.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
