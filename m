From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: remove unused dma_head & dma_maps fields
Date: Wed, 24 Mar 2010 11:13:50 -0700 (PDT)
Message-ID: <20100324.111350.158441178.davem@davemloft.net>
References: <20100324064049.32298.87859.stgit@localhost.localdomain>
	<1269413286.2915.107.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752793Ab0CXSN1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 14:13:27 -0400
In-Reply-To: <1269413286.2915.107.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 07:48:06 +0100

> Le mardi 23 mars 2010 =E0 23:40 -0700, Jeff Kirsher a =E9crit :
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>=20
>> The dma map fields in the skb_shared_info structure no longer has an=
y users
>> and can be dropped since it is making the skb_shared_info unecessari=
ly larger.
>>=20
>> Running slabtop show that we were using 4K slabs for the skb->head o=
n x86_64 w/
>> an allocation size of 1522.  It turns out that the dma_head and dma_=
maps array
>> made skb_shared large enough that we had crossed over the 2k boundar=
y with
>> standard frames and as such we were using 4k blocks of memory for al=
l skbs.
>>=20
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>=20
>=20
> Thanks a lot for doing this cleanup !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Yep, thanks indeed.  Applied!
