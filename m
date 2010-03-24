From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skbuff: remove unused dma_head & dma_maps fields
Date: Wed, 24 Mar 2010 07:48:06 +0100
Message-ID: <1269413286.2915.107.camel@edumazet-laptop>
References: <20100324064049.32298.87859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:52103 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab0CXGsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:48:11 -0400
Received: by bwz1 with SMTP id 1so2573360bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 23:48:09 -0700 (PDT)
In-Reply-To: <20100324064049.32298.87859.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 23:40 -0700, Jeff Kirsher a =C3=A9crit :
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> The dma map fields in the skb_shared_info structure no longer has any=
 users
> and can be dropped since it is making the skb_shared_info unecessaril=
y larger.
>=20
> Running slabtop show that we were using 4K slabs for the skb->head on=
 x86_64 w/
> an allocation size of 1522.  It turns out that the dma_head and dma_m=
aps array
> made skb_shared large enough that we had crossed over the 2k boundary=
 with
> standard frames and as such we were using 4k blocks of memory for all=
 skbs.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20

Thanks a lot for doing this cleanup !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



