From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Tue, 12 Apr 2011 13:39:23 -0700 (PDT)
Message-ID: <20110412.133923.193703393.davem@davemloft.net>
References: <20110412164557.GF2047@stratus.com>
	<1302627281.3233.70.camel@edumazet-laptop>
	<1302628720.3233.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, jluebbe@debian.org, lkml@scotdoyle.com,
	shimoda.hiroaki@gmail.com, netdev@vger.kernel.org,
	bandan.das@stratus.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757357Ab1DLUkB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 16:40:01 -0400
In-Reply-To: <1302628720.3233.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Apr 2011 19:18:40 +0200

> Commit 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP
> stack), missed one IPCB init before calling ip_options_compile()
>=20
> Thanks to Scot Doyle for his tests and bug reports.
>=20
> Reported-by: Scot Doyle <lkml@scotdoyle.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Acked-by: Bandan Das <bandan.das@stratus.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jan L=FCbbe <jluebbe@debian.org>

Applied, thanks everyone.
