From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Thu, 18 Nov 2010 18:39:23 +0100
Message-ID: <1290101963.2781.234.camel@edumazet-laptop>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
	 <1289976990.2732.226.camel@edumazet-laptop>  <4CE5621F.8040503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43991 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267Ab0KRRjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:39:37 -0500
Received: by wwa36 with SMTP id 36so3593983wwa.1
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 09:39:36 -0800 (PST)
In-Reply-To: <4CE5621F.8040503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 09:27 -0800, John Fastabend a =C3=A9cr=
it :

> Thanks for the feedback!
>=20
> num_tx_queues is an unsigned int in net_device and I can't see any
> place that would limit it to 16bits. So I think we need 32 bits here.
> Otherwise I will make these changes and fix the fallout. This is much
> cleaner.
>=20
>=20

Hmm...

include/linux/skbuff.h

__u16           queue_mapping:16;


static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_queu=
e)

Anyway, we dont want to have more than 32768 queues, not before year
2020 at least

Thanks



