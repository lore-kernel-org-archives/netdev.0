From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 09/10] IPV4: use rcu to walk list of devices in IGMP
Date: Tue, 10 Nov 2009 19:47:34 +0100
Message-ID: <4AF9B546.5090805@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.754389168@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58000 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbZKJSrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:47:32 -0500
In-Reply-To: <20091110175647.754389168@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This also needs to be optimized for large number of devices.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> =20

>  static void igmp_mcf_seq_stop(struct seq_file *seq, void *v)
> +	__releases(rcu)

Minor note : we usually use RCU instead of rcu, but it doesnt really ma=
tter.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

