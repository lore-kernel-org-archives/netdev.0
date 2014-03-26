From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: powerpc: net: gianfar ethernet broken on linux-3.10.29?
Date: Wed, 26 Mar 2014 15:02:41 +0200
Message-ID: <5332CFF1.5080402@freescale.com>
References: <1385350976.279693.1395775567178.JavaMail.root@mail>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Cane, Romeo (EXT-Other PT/Amadora)" <romeo.cane.ext@coriant.com>
To: =?UTF-8?B?w4ltZXJpYyBWaWdpZXI=?=
	<emeric.vigier@savoirfairelinux.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:10049
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956AbaCZNC7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 09:02:59 -0400
In-Reply-To: <1385350976.279693.1395775567178.JavaMail.root@mail>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/25/2014 9:26 PM, =C3=89meric Vigier wrote:
> Hi guys,
>
> I work on a Freescale MPC8347 custom board. I ported u-boot-v2014.01 =
on it. My config is attached.
> I ported linux-3.2.52 (long-term). DTS is attached.
>
[...]
>
> Do you guys see what could be wrong in my config?
> Or what has changed in linux-3.{4,6,8,10} that could break my etherne=
t?
>
> thanks,
> Emeric
>

Hi Emeric,

Thanks for the detailed logs.
You may refer to Romeo's issue:
http://permalink.gmane.org/gmane.linux.network/309587

There's this stable fix for the (older) TSEC controllers:
commit 5eaedf31319d5f80eaaee1eec8dd18c0b452f0d1
("gianfar: Add backwards compatible Single Queue mode polling")

that for some reason was not included in kernel 3.10
(but it was included in kernel 3.11).

Hi David,
Can we have this gianfar fix included in kernel 3.10 as well?
Is there anything I can do to help with this?

Thanks and regards,
Claudiu
