From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Fri, 5 Sep 2008 20:37:46 +0400
Message-ID: <20080905163746.GA450@2ka.mipt.ru>
References: <bug-11469-10286@http.bugzilla.kernel.org/> <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080905114146.GA29408@2ka.mipt.ru> <200809051903.41103.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36803 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbYIEQio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 12:38:44 -0400
Content-Disposition: inline
In-Reply-To: <200809051903.41103.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Sep 05, 2008 at 07:03:38PM +0300, R=C3=A9mi Denis-Courmont (rde=
nis@simphalempin.com) wrote:
> > Does this problem still exist?
>=20
> Yes. With 2.6.27-rc5-b380b0d4f7dffcc235c0facefa537d4655619101, I get =
this:

I will try to work it out this weekend, thanks for the info.

> > > > Pid: 9950, comm: tunload Tainted: G      D   (2.6.26.3 #8)
> >
> > By whom it was tainted?
>=20
> Its own self. I just failed to copy the very first crash trace.

Likely it will not help, since subsequent crashes are results of the
first one and rarely contain good info, but dump you have presented is
not tainted, so problem is not in some other place.

--=20
	Evgeniy Polyakov
