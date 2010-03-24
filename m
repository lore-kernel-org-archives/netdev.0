From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: only use vlan_gro_receive if vlans are registered
Date: Tue, 23 Mar 2010 23:21:15 -0700 (PDT)
Message-ID: <20100323.232115.38318934.davem@davemloft.net>
References: <20100324043517.32036.81274.stgit@localhost.localdomain>
	<1269409837.2915.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799Ab0CXGUw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 02:20:52 -0400
In-Reply-To: <1269409837.2915.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 06:50:37 +0100

> Le mardi 23 mars 2010 =E0 21:35 -0700, Jeff Kirsher a =E9crit :
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>=20
>> This change makes it so that vlan_gro_receive is only used if vlans =
have been
>> registered to the adapter structure.  Previously we were just sendin=
g all vlan
>> tagged frames in via this function but this results in a null pointe=
r
>> dereference when vlans are not registered.
>>=20
>=20
> This patch fixes bugzilla entry 15582

I've added a note about this to the commit message.

>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
