From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH v2] atm: expose ATM device index in sysfs
Date: Fri, 27 May 2011 16:05:41 +0100
Message-ID: <1306508748.2029.124.camel@i7.infradead.org>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
	 <1306432509.2543.1.camel@edumazet-laptop>
	 <1306434959.3151.39.camel@dcbw.foobar.com>
	 <1306507915.22126.2.camel@dcbw.foobar.com>
	 <1306508269.3445.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54508 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab1E0PFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 11:05:53 -0400
In-Reply-To: <1306508269.3445.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-27 at 16:57 +0200, Eric Dumazet wrote:
> Le vendredi 27 mai 2011 =C3=A0 09:51 -0500, Dan Williams a =C3=A9crit=
 :
> > It's currently exposed only through /proc which, besides requiring
> > screen-scraping, doesn't allow userspace to distinguish between two
> > identical ATM adapters with different ATM indexes.  The ATM device =
index
> > is required when using PPPoATM on a system with multiple ATM adapte=
rs.
> >=20
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > ---
> >=20
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

Tested-by: David Woodhouse <dwmw2@infradead.org>
Cc: stable@kernel.org

[root@solos atm]# grep ^ /sys/class/atm/*/atmindex
/sys/class/atm/solos-pci0/atmindex:0
/sys/class/atm/solos-pci1/atmindex:1

--=20
dwmw2

