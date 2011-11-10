From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REPOST patch net-next V6] net: introduce ethernet teaming
 device
Date: Thu, 10 Nov 2011 08:02:19 +0100
Message-ID: <1320908539.16265.2.camel@edumazet-laptop>
References: <1320876793-1158-1-git-send-email-jpirko@redhat.com>
	 <1320880355.5825.1.camel@edumazet-laptop>
	 <20111110064807.GB2058@minipsycho>
	 <1320907983.16265.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57425 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1KJHCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 02:02:25 -0500
Received: by wwh12 with SMTP id 12so1873401wwh.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 23:02:24 -0800 (PST)
In-Reply-To: <1320907983.16265.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 07:53 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 10 novembre 2011 =C3=A0 07:48 +0100, Jiri Pirko a =C3=A9crit=
 :
>=20
> > dev_kfree_skb is called from module transmit functions to handle fr=
ee of
> > skb when needed. But I see now that in case when
> > (likely(!list_empty(&team->port_list) && team->mode_ops.transmit)) =
=3D=3D false
> > this would leak. I'm going to rewrite this bit somehow.
>=20
> This is the leak I mentioned, I thought it was obvious :)
>=20
> If you return NETDEV_TX_OK, then the skb must have been consumed.

I meant : consumed or queued in a device transmit queue...
