From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb/ixgbe: set
 NETIF_F_HIGHDMA for VLAN feature flags
Date: Wed, 22 Sep 2010 23:06:41 -0700
Message-ID: <AANLkTikDdxFho2ioBHMbze685+garDWF9kF3qFXZA9Hr@mail.gmail.com>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
	<20100922.212023.91330415.davem@davemloft.net>
	<1285219690.2380.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, yi.zou@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62799 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931Ab0IWGGm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 02:06:42 -0400
Received: by iwn5 with SMTP id 5so1173692iwn.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 23:06:42 -0700 (PDT)
In-Reply-To: <1285219690.2380.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 22, 2010 at 22:28, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Le mercredi 22 septembre 2010 =C3=A0 21:20 -0700, David Miller a =C3=A9=
crit :
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Wed, 22 Sep 2010 20:57:58 -0700
>>
>> > From: Yi Zou <yi.zou@intel.com>
>> >
>> > If the netdev->features is set with NETIF_F_HIGHDMA, we should set=
 the
>> > corresponding netdev->vlan_features as well to allow VLAN netdev c=
reated
>> > on top of the real netdev to be able to also benefit from HIGHDMA =
on 32bit
>> > system, reducing the performance hit that is caused by __skb_linea=
rize(),
>> > particularly for large send. This is fixed in this patch for all I=
ntel e1000,
>> > e1000e, igb, ixgbe, and ixgbe drivers since this should be benefic=
ial
>> > to all devices supported by these drivers.
>> >
>> > Signed-off-by: Yi Zou <yi.zou@intel.com>
>> > Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>
>> Applied.
>
>
> Maybe this could be done in core network.
>
>

Good suggestion!  Do you plan on making a patch Eric?  Let me know of
any assistance
you need with the Intel LAN dirvers.
