From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 17:20:02 +0200
Message-ID: <1286378402.9417.21.camel@edumazet-laptop>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	 <1286256926.2457.2.camel@edumazet-laptop>  <4CAB4D8F.8080108@intel.com>
	 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
	 <4CAB6447.6040407@intel.com>  <4CAC8D11.2060604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63248 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521Ab0JFPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 11:20:10 -0400
Received: by fxm4 with SMTP id 4so1212596fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 08:20:09 -0700 (PDT)
In-Reply-To: <4CAC8D11.2060604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 octobre 2010 =C3=A0 07:52 -0700, John Fastabend a =C3=A9=
crit :

> If I update the handful drivers that use netif_set_real_num_rx_queues=
()
> before the netdevice is registered to explicitly set num_rx_queues th=
is
> would address Eric's concerns and fix drivers that really only want t=
o set
> real_num_rx_queue.
>=20

John, it seems current API is not very clean/orthogonal.

If you believe a driver can increase real_num_rx_queue, then we should
apply your patch, and refine API if necessary.

We now allocate rx queues in register_netdevice(), maybe we should do
the same for tx queues.



