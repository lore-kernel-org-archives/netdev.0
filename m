From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 0/4] Netfilter/iptables performance improvements
Date: Wed, 18 Feb 2009 09:30:08 +0100
Message-ID: <499BC710.2010906@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60567 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbZBRIag convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 03:30:36 -0500
In-Reply-To: <20090218051906.174295181@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Bring together the three performance improvements suggested.
>   1) RCU for ip_tables entries
>   2) mod_timer_noact for conntrack timer
>   3) eliminate tcp_lock
>=20
> I took the patches for 2 & 3 and made them build and basically work.
>=20
> This patch set is against Patrick's netfilter next tree since
> it is where it should end up.
> 	git.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
>=20

Excellent Stephen, I'll give some time today to review this and test it
on my lab machines.

