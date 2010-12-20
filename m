From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2] net: implement mechanism for HW based
 QOS
Date: Mon, 20 Dec 2010 23:58:51 +0100
Message-ID: <1292885931.2627.128.camel@edumazet-laptop>
References: <20101217165622.26608.24819.stgit@jf-dev1-dcblab>
	 <1292885287.3055.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, nhorman@tuxdriver.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55859 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757821Ab0LTW64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 17:58:56 -0500
Received: by wyb28 with SMTP id 28so3385220wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 14:58:55 -0800 (PST)
In-Reply-To: <1292885287.3055.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 22:48 +0000, Ben Hutchings a =C3=A9=
crit :

> That seems like a fair amount of data to add to every net device,
> considering that users may create e.g. a lot of VLAN devices and they
> won't use this state at all.  Have you considered putting these in a
> structure that is accessed indirectly?

Yes, this was like this in previous patch, but I asked John to put it i=
n
netdevice instead, in order to avoid a false sharing and this
indirection.

This adds 64 bytes on a netdevice. Most machines dont have more than 16
netdevices, it seems a reasonable cost. (We removed the ingress bloat
some time ago, so no significant increase anyway)



