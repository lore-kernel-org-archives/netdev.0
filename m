From: <Narendra_K@Dell.com>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Fri, 31 May 2013 05:17:49 -0700
Message-ID: <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>
 <87fvx4mvtl.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>
To: <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:40194 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab3EaMSS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 08:18:18 -0400
In-Reply-To: <87fvx4mvtl.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 07:08:46PM +0530, Bj=F8rn Mork wrote:
>=20
> <Narendra_K@Dell.com> writes:
>=20
> > From: Narendra K <narendra_k@dell.com>
> >
> > 'dev_id' sysfs attribute is initialized to zero by default.
> > It is also zero based. This creates ambiguity in differentiating
> > whether the driver set it to zero or it is the default value.
> > Initialize 'dev_id' to -1 to make the scenario unambiguous.
>=20
> I understand your concern, but I don't think you can do this.  It
> changes the userspace API, and has some very visible side effects.
>=20
> Please take a look at net/ipv6/addrconf.c

Ok, thank you for pointing it. I missed it while looking for its
possible use scenarios.

With regards,
Narendra K
Linux Engineering
Dell Inc.
