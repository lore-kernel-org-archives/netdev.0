From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Thu, 18 Nov 2010 10:00:51 -0800
Message-ID: <4CE569D3.7060504@intel.com>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>	 <1289976990.2732.226.camel@edumazet-laptop>  <4CE5621F.8040503@intel.com> <1290101963.2781.234.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60904 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759984Ab0KRSAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 13:00:53 -0500
In-Reply-To: <1290101963.2781.234.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2010 9:39 AM, Eric Dumazet wrote:
> Le jeudi 18 novembre 2010 =C3=A0 09:27 -0800, John Fastabend a =C3=A9=
crit :
>=20
>> Thanks for the feedback!
>>
>> num_tx_queues is an unsigned int in net_device and I can't see any
>> place that would limit it to 16bits. So I think we need 32 bits here=
=2E
>> Otherwise I will make these changes and fix the fallout. This is muc=
h
>> cleaner.
>>
>>
>=20
> Hmm...
>=20
> include/linux/skbuff.h
>=20
> __u16           queue_mapping:16;
>=20
>=20
> static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_qu=
eue)
>=20
> Anyway, we dont want to have more than 32768 queues, not before year
> 2020 at least
>=20
> Thanks
>=20
>=20
>=20

Ah a u16 it is then. And more then 32768 queues would be a bit much.
