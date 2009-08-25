From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [Patch] Fix commit 63d9950b08184e6531adceb65f64b429909cc101
 (ipv6: Make v4-mapped bindings consistent with IPv4)
Date: Tue, 25 Aug 2009 22:20:42 +0200
Message-ID: <20090825222042.4d13aacd@neptune.home>
References: <20090822011541.7b95dbcc@neptune.home>
 <20090822014523.3ec2f591@neptune.home>
 <20090823.190715.124304781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-152-237.adsl.restena.lu ([158.64.152.237]:39538 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168AbZHYUaK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 16:30:10 -0400
In-Reply-To: <20090823.190715.124304781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 August 2009 David Miller <davem@davemloft.net> wrote:
> From: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
> Date: Sat, 22 Aug 2009 01:45:23 +0200
>=20
> > Commit 63d9950b08184e6531adceb65f64b429909cc101
> >   (ipv6: Make v4-mapped bindings consistent with IPv4)
> > changes behavior of inet6_bind() for v4-mapped addresses so it
> > should behave the same way as inet_bind().
> >=20
> > During this change setting of err to -EADDRNOTAVAIL got lost:
>  ...
> > Signed-off-by Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
>=20
> Thanks for finding and fixing this bug, applied, thanks!

Please consider queueing this for 2.6.30.x stable, upstream commit is
ca6982b858e1d08010c1d29d8e8255b2ac2ad70a

Bruno
