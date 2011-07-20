From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 35/47] e1000: do vlan cleanup
Date: Wed, 20 Jul 2011 10:48:32 -0700
Message-ID: <CAEP_g=-XJaq6KSwXXUzeFcqAo3WVWHCLyuqGYjcriRQiKO56bw@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com> <1311173689-17419-36-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:35875 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab1GTRsw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 13:48:52 -0400
Received: by yxi11 with SMTP id 11so226294yxi.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:48:52 -0700 (PDT)
In-Reply-To: <1311173689-17419-36-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> @@ -4532,9 +4539,8 @@ static void e1000_vlan_rx_register(struct net_d=
evice *netdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!test_bit(__E1000_DOWN, &adapter->flag=
s))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_irq_disa=
ble(adapter);
> - =C2=A0 =C2=A0 =C2=A0 adapter->vlgrp =3D grp;
>
> - =C2=A0 =C2=A0 =C2=A0 if (grp) {
> + =C2=A0 =C2=A0 =C2=A0 if (vlan_on) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* enable VLAN=
 tag insert/strip */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ctrl =3D er32(=
CTRL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ctrl |=3D E100=
0_CTRL_VME;

Same comment here as with the igb driver.
