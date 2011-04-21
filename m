From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Thu, 21 Apr 2011 18:08:14 +0200
Message-ID: <1303402094.3685.54.camel@edumazet-laptop>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58551 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1DUQIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 12:08:18 -0400
Received: by wwa36 with SMTP id 36so2267708wwa.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 09:08:17 -0700 (PDT)
In-Reply-To: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 avril 2011 =C3=A0 23:50 +0800, zhou rui a =C3=A9crit :
> kernel 2.6.36.4
> CONFIG_RPS=3Dy but not set the cpu mask
>=20
> /sys/class/net/eth1/queues/rx-0 # cat rps_cpus
> 00
>=20
> register a hook func:
>   prot_hook.func =3D packet_rcv;
>   prot_hook.type =3D htons(ETH_P_ALL);
>   dev_add_pack(&prot_hook);
>=20
>=20
> replay the same traffic in very slow speed, printk the
> smp_processor_id in packet_rcv():
> first time:
> cpu=3D4
> cpu=3D3
> cpu=3D6
> cpu=3D7
>=20
> second time:
> cpu=3D7
> cpu=3D1
> cpu=3D5
> cpu=3D2
>=20
> is it normal?

Yes it is.

What would you expect ?


