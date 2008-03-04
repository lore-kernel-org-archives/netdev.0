From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Tue, 04 Mar 2008 07:27:52 +0100
Message-ID: <47CCEBE8.2000402@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com>	<20080226.182120.183405235.davem@davemloft.net>	<47C92F49.4070100@cosmosbay.com> <20080303.205558.114610030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:33572
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbYCDG2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 01:28:05 -0500
In-Reply-To: <20080303.205558.114610030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 01 Mar 2008 11:26:17 +0100
>=20
>> You are absolutly right. We should guard against recursion, using a =
new field=20
>> in "pcpu_lstats" (cheap access in a hot cache line as we have to upd=
ate stats=20
>> anyway)
>  ...
>> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
>=20
> I'm willing to seriously entertain this change and stick it
> into net-2.6.26 if you will perform a reasonable deep stack
> test.
>=20
> For example, create an XFS filesystem, and mount it NFS over
> loopback.  Then stress it like crazy.
>=20
> See if this generates stack overflows or weird crashes.
>=20
>=20

=46air enough :)

I'll do my best to stress it on various situations, with 4K stacks on i=
386.

Thank you
