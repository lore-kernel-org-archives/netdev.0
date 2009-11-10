From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 02/10] vlan: eliminate use of dev_base_lock
Date: Tue, 10 Nov 2009 19:20:15 +0100
Message-ID: <4AF9AEDF.2070307@cosmosbay.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.268344307@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33107 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbZKJSUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:20:15 -0500
In-Reply-To: <20091110175647.268344307@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Do not need to use read_lock(&dev_base_lock), use RCU instead.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


