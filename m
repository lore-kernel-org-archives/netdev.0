From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] af-packet:  Add flag to distinguish VID 0 from
 no-vlan.
Date: Wed, 01 Jun 2011 19:08:32 +0200
Message-ID: <1306948112.2890.6.camel@edumazet-laptop>
References: <1306946950-29360-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33915 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379Ab1FARIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:08:35 -0400
Received: by wwa36 with SMTP id 36so15274wwa.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 10:08:34 -0700 (PDT)
In-Reply-To: <1306946950-29360-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 juin 2011 =C3=A0 09:49 -0700, greearb@candelatech.com a
=C3=A9crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> Currently, user-space cannot determine if a 0 tcp_vlan_tci
> means there is no VLAN tag or the VLAN ID was zero.
>=20
> Add flag to make this explicit.  User-space can check for
> TP_STATUS_VLAN_VALID || tp_vlan_tci > 0, which will be backwards
> compatible. Older could would have just checked for tp_vlan_tci,
> so it will work no worse than before.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


