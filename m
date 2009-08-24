From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Fix commit 63d9950b08184e6531adceb65f64b429909cc101
 (ipv6: Make v4-mapped bindings consistent with IPv4)
Date: Sun, 23 Aug 2009 19:07:15 -0700 (PDT)
Message-ID: <20090823.190715.124304781.davem@davemloft.net>
References: <20090822011541.7b95dbcc@neptune.home>
	<20090822014523.3ec2f591@neptune.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: bonbons@linux-vserver.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59072
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200AbZHXCHF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 22:07:05 -0400
In-Reply-To: <20090822014523.3ec2f591@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bruno Pr=E9mont <bonbons@linux-vserver.org>
Date: Sat, 22 Aug 2009 01:45:23 +0200

> Commit 63d9950b08184e6531adceb65f64b429909cc101
>   (ipv6: Make v4-mapped bindings consistent with IPv4)
> changes behavior of inet6_bind() for v4-mapped addresses so it should
> behave the same way as inet_bind().
>=20
> During this change setting of err to -EADDRNOTAVAIL got lost:
 ...
> Signed-off-by Bruno Pr=E9mont <bonbons@linux-vserver.org>

Thanks for finding and fixing this bug, applied, thanks!
