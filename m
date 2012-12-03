From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Mon, 3 Dec 2012 17:43:33 +0000
Message-ID: <1354556613.2819.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	 <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	 <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	 <50A570D7.3080409@gmail.com>
	 <1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
	 <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
	 <1353094719.2743.21.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA9f3y1mDPubqd9s+v5supj3hNvZaWym0_y3EMZd7L6MyQ@mail.gmail.com>
	 <1354335498.2640.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_Ar8rnWE14Dq6uJHhrMY9ttEE4XcWg88jcVe4zc=_e8g@mail.gmail.com>
	 <CAPN4dA8+RHq1BAEjXv2tQHQw_h0JhEoah0HCq65k63gmszjLCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40031 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402Ab2LCRng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 12:43:36 -0500
In-Reply-To: <CAPN4dA8+RHq1BAEjXv2tQHQw_h0JhEoah0HCq65k63gmszjLCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-02 at 23:00 +0100, Aur=C3=A9lien wrote:
> On Sun, Dec 2, 2012 at 10:47 PM, Aur=C3=A9lien <footplus@gmail.com> w=
rote:
> >>
> >> This version drops the -lm completely, so it doesn't link.  Maybe =
you
> >> edited the generated Makefile or Makefile.in?
> >
> > No, I just stupidly forgot to make distclean & autogen after removi=
ng
> > all libm checks. Re-added AC_CHECK_LIB to link with it.
> >
>=20
> Just after re-reading this, I thought it was silly; I instead edited
> Makefile.am and reverted the configure.ac change. Here's a new
> full-patch with that fix along with the rest.
>=20
> Sorry for the noise.

Applied, thanks.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
