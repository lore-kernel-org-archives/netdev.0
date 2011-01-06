From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 1/2] net: implement mechanism for HW
 based QOS
Date: Thu, 06 Jan 2011 19:56:31 +0100
Message-ID: <1294340191.3074.96.camel@edumazet-laptop>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>
	 <1294338015.11825.26.camel@bwh-desktop>
	 <1294338690.3074.91.camel@edumazet-laptop>  <4D260DC2.6050601@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jarkao2@gmail.com" <jarkao2@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54994 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1AFS4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:56:44 -0500
Received: by wwa36 with SMTP id 36so17713502wwa.1
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 10:56:42 -0800 (PST)
In-Reply-To: <4D260DC2.6050601@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 10:45 -0800, John Fastabend a =C3=A9cri=
t :

> It should still be 64 bytes.
>=20
> struct netdev_tc_txq {
>         u16 count;
>         u16 offset;
> };
>=20
> struct netdev_tc_txq (4 octets) and TC_MAX_QUEUE =3D 16, so 4*16 =3D =
64
>=20
> +	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];   =3D> 64 octets
> +	u8 prio_tc_map[TC_BITMASK+1];			=3D> 16 octets
>=20
> All together 80 bytes this is certainly in the 512 unused bytes.

Good ;)

Considering a single TCP socket is larger than a net_device, I think it=
s
OK to not worry too much ;)



