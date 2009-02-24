From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: !CONFIG_NET_NS build error, net/core/net_namespace.c
Date: Tue, 24 Feb 2009 14:43:16 +0100
Message-ID: <49A3F974.5030801@free.fr>
References: <1235480427.5965.22.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:49881 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbZBXNoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 08:44:22 -0500
In-Reply-To: <1235480427.5965.22.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Galbraith wrote:
>   CC      net/core/net_namespace.o
> net/core/net_namespace.c: In function =E2=80=98net_ns_init=E2=80=99:
> net/core/net_namespace.c:223: error: implicit declaration of function=
 =E2=80=98net_alloc_generic=E2=80=99
> net/core/net_namespace.c:223: warning: assignment makes pointer from =
integer without a cast
> make[2]: *** [net/core/net_namespace.o] Error 1
> make[1]: *** [net/core] Error 2
> make: *** [net] Error 2
>
>  =20
Thanks, this has been fixed with commit=20
ebe47d47b7b7fed72dabcce4717da727b4e2367d
Sorry for the inconvenience.

  -- Daniel
