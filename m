From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] vlan: eliminate use of dev_base_lock
Date: Tue, 10 Nov 2009 22:47:43 -0800 (PST)
Message-ID: <20091110.224743.170065362.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.268344307@vyatta.com>
	<4AF9AEDF.2070307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbZKKGrR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:47:17 -0500
In-Reply-To: <4AF9AEDF.2070307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 10 Nov 2009 19:20:15 +0100

> Stephen Hemminger a =E9crit :
>> Do not need to use read_lock(&dev_base_lock), use RCU instead.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
