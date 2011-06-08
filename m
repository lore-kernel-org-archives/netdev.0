From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [af-packet 1/2] Enhance af-packet to provide (near
 zero)lossless packet capture functionality.
Date: Wed, 08 Jun 2011 06:35:54 +0200
Message-ID: <1307507754.3102.18.camel@edumazet-laptop>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	 <1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	johann.baudy@gnu-log.net, Chetan Loke <lokec@ccs.neu.edu>
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48650 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1FHEf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 00:35:59 -0400
Received: by wya21 with SMTP id 21so71147wya.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 21:35:58 -0700 (PDT)
In-Reply-To: <1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 juin 2011 =C3=A0 23:13 -0400, Chetan Loke a =C3=A9crit :
> =20
> +struct tpacket3_hdr {
> +	__u32		tp_status;
> +	__u32		tp_len;
> +	__u32		tp_snaplen;
> +	__u16		tp_mac;
> +	__u16		tp_net;

> +	__u32		tp_sec;
> +	__u32		tp_nsec;
> +	__u16		tp_vlan_tci;

missing "__u16 tp_padding;" here

check :

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
it;h=3D13fcb7bd322164c67926ffe272846d4860196dc6


> +	__u32		tp_next_offset;
> +};



