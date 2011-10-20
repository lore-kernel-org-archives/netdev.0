From: David Miller <davem@davemloft.net>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 16:24:44 -0400 (EDT)
Message-ID: <20111020.162444.559487256559727633.davem@davemloft.net>
References: <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1318946401.23980.6.camel@deadeye>
	<1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, daniel.turull@gmail.com,
	netdev@vger.kernel.org, robert@herjulf.net, voravit@kth.se,
	jens.laas@uadm.uu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab1JTU2H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:28:07 -0400
In-Reply-To: <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 16:47:44 +0200

> Le mardi 18 octobre 2011 =E0 15:00 +0100, Ben Hutchings a =E9crit :
>=20
>> AIUI, the reason for limits on delays is not that it's bad practice =
to
>> spin for so long, but that the delay calculations may overflow or
>> otherwise become inaccurate.
>=20
> OK, I can understand that, then a more appropriate patch would be :

I think doing the udelay/ndelay thing is the way to go for 'net' and
-stable.  We can do something sophisticated with ktime et al. in
'net-next'.

Eric, could you please formally submit this patch with proper
changelog etc.?

Thanks.
