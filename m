From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] atm: expose ATM device index in sysfs
Date: Fri, 27 May 2011 13:07:34 -0400 (EDT)
Message-ID: <20110527.130734.854844547751451297.davem@davemloft.net>
References: <1306507915.22126.2.camel@dcbw.foobar.com>
	<1306508269.3445.0.camel@edumazet-laptop>
	<1306508748.2029.124.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab1E0RKs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 13:10:48 -0400
In-Reply-To: <1306508748.2029.124.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 27 May 2011 16:05:41 +0100

> On Fri, 2011-05-27 at 16:57 +0200, Eric Dumazet wrote:
>> Le vendredi 27 mai 2011 =E0 09:51 -0500, Dan Williams a =E9crit :
>> > It's currently exposed only through /proc which, besides requiring
>> > screen-scraping, doesn't allow userspace to distinguish between tw=
o
>> > identical ATM adapters with different ATM indexes.  The ATM device=
 index
>> > is required when using PPPoATM on a system with multiple ATM adapt=
ers.
>> >=20
>> > Signed-off-by: Dan Williams <dcbw@redhat.com>
>> > ---
>> >=20
>>=20
>> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Tested-by: David Woodhouse <dwmw2@infradead.org>
> Cc: stable@kernel.org
>=20
> [root@solos atm]# grep ^ /sys/class/atm/*/atmindex
> /sys/class/atm/solos-pci0/atmindex:0
> /sys/class/atm/solos-pci1/atmindex:1

Applied, thanks.
