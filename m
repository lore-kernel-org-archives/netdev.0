From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: restore multicast and rx_errors fields
Date: Wed, 07 Mar 2012 06:44:51 -0800
Message-ID: <1331131491.2474.71.camel@edumazet-laptop>
References: <1331099201.2474.59.camel@edumazet-laptop>
	 <20120307141704.GA11924@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Anton Blanchard <anton@samba.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:42178 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab2CGOpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 09:45:00 -0500
Received: by gghe5 with SMTP id e5so2146346ggh.19
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2012 06:44:58 -0800 (PST)
In-Reply-To: <20120307141704.GA11924@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 mars 2012 =C3=A0 11:17 -0300, Thadeu Lima de Souza Casca=
rdo a
=C3=A9crit :

> Tested, in particular, the multicast stat, pinging 224.0.0.1 from
> another machine.
>=20
> Thanks.
> Cascardo.
>=20
> Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com=
>
>=20

Thanks !

Maybe you could submit a followup patch, to remove the port->stats
structure and only use two u64 fields, since this driver only use two
counters in its private "stats" ?

(I cant compile this driver on my dev machine)
