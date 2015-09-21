From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] iptunnel: make rx/tx bytes counters consistent
Date: Mon, 21 Sep 2015 09:39:00 +0200
Message-ID: <55FFB414.4000800@6wind.com>
References: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150920.223513.1872161134519661761.davem@davemloft.net>
 <20150920.223749.1379178493985547245.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37236 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755825AbbIUHjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 03:39:04 -0400
Received: by wicfx3 with SMTP id fx3so98397377wic.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 00:39:03 -0700 (PDT)
In-Reply-To: <20150920.223749.1379178493985547245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/09/2015 07:37, David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Sun, 20 Sep 2015 22:35:13 -0700 (PDT)
>
>>> After the patch:
>>> $ ping -c1 192.168.0.121 ; ip -s l ls dev gre1
>>> PING 192.168.0.121 (192.168.0.121) 56(84) bytes of data.
>>> 64 bytes from 192.168.0.121: icmp_req=3D1 ttl=3D64 time=3D2.95 ms
>>>
>>> --- 192.168.0.121 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev =3D 2.955/2.955/2.955/0.000 ms
>
> BTW, when you includ PING output in a commit message like this
> it really makes things difficult.
>
> "---" denotes end of the commit as far as tools like "git am"
> are concerned.
>
> I happened to notice this time and fix up the commit messages by hand=
,
> but it'd be much better if it weren't left up to chance like that.
Oh ok. I will take care of that next time.

Thank you for fixing it.


Regards,
Nicolas
