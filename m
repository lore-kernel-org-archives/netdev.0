From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Wed, 06 Oct 2010 17:23:46 +0200
Message-ID: <1286378626.9417.24.camel@edumazet-laptop>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
	 <1286256926.2457.2.camel@edumazet-laptop>  <4CAB4D8F.8080108@intel.com>
	 <1286296476.2307.5.camel@achroite.uk.solarflarecom.com>
	 <4CAB6447.6040407@intel.com>  <4CAC8D11.2060604@intel.com>
	 <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39247 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759143Ab0JFPXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 11:23:53 -0400
Received: by fxm4 with SMTP id 4so1216332fxm.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 08:23:52 -0700 (PDT)
In-Reply-To: <1286377633.2371.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 octobre 2010 =C3=A0 16:07 +0100, Ben Hutchings a =C3=A9c=
rit :

> The waste of memory is minimal now that we only allocate kobjects for
> real_num_rx_queues.

Thats strange, here with tg3 (and mono queue device) :

0a:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S
Gigabit Ethernet (rev a3)

grep . /sys/class/net/eth2/queues/rx-*/rps_cpus
/sys/class/net/eth2/queues/rx-0/rps_cpus:00000000
/sys/class/net/eth2/queues/rx-1/rps_cpus:00000000
/sys/class/net/eth2/queues/rx-2/rps_cpus:00000000
/sys/class/net/eth2/queues/rx-3/rps_cpus:00000000
/sys/class/net/eth2/queues/rx-4/rps_cpus:00000000



