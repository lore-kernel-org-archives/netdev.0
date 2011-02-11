From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Fri, 11 Feb 2011 07:46:18 -0800
Message-ID: <AANLkTi=wwZRe4y0s0jOUHafywJT_Ag=RRnrM9DeUQhJ+@mail.gmail.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60910 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757501Ab1BKPqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 10:46:19 -0500
Received: by iyj8 with SMTP id 8so2533983iyj.19
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 07:46:18 -0800 (PST)
In-Reply-To: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 13:59,  <greearb@candelatech.com> wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> This allows the NIC to receive 1518 byte (not counting
> FCS) packets when MTU is 1500, thus allowing 1500 MTU
> VLAN frames to be received. =C2=A0Please note that no VLANs
> were actually configured on the NIC...it was just acting
> as pass-through device.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 58c665b... 30c9cc6... M =C2=A0drivers/net/igb/igb_main=
=2Ec
> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 =C2=A05 +++--
> =C2=A01 files changed, 3 insertions(+), 2 deletions(-)
>

Thanks Ben, I have added the patch to my queue of igb patches.

--=20
Cheers,
Jeff
