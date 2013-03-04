From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: NET: FEC: dynamtic check DMA desc buff type
Date: Mon, 04 Mar 2013 15:06:51 +1000
Message-ID: <51342BEB.5020004@uclinux.org>
References: <513415C1.2070904@uclinux.org> <CAHrpEqS_nrBzHr23vQrukQE0XmxP5EVWB44aOcMQctjzYqgnGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Li <Frank.Li@freescale.com>,
	Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	lkml@vger.kernel.org
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail02.westnet.com.au ([203.10.1.243]:23346 "EHLO
	outbound-mail02.westnet.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750943Ab3CDFHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 00:07:00 -0500
In-Reply-To: <CAHrpEqS_nrBzHr23vQrukQE0XmxP5EVWB44aOcMQctjzYqgnGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Frank,

On 04/03/13 14:35, Frank Li wrote:
> 2013/3/4 Greg Ungerer <gerg@uclinux.org>:
>> Commit ff43da86c69d76a726ffe7d1666148960dc1d108 ("NET: FEC: dynamtic
>> check DMA desc buff type") breaks building of the fec ethernet drive=
r
>> for non CONFIG_ARCH_MXC targets.
>>
>> For example building for ColdFire devices with FEC hardware now
>> fails like this
>>
>> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_ne=
xtdesc=92:
>> drivers/net/ethernet/freescale/fec.c:215:18: error: invalid use of u=
ndefined
>> type =91struct bufdesc_ex=92
>> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_get_pr=
evdesc=92:
>> drivers/net/ethernet/freescale/fec.c:224:18: error: invalid use of u=
ndefined
>> type =91struct bufdesc_ex=92
>> drivers/net/ethernet/freescale/fec.c: In function =91fec_enet_start_=
xmit=92:
>> drivers/net/ethernet/freescale/fec.c:286:37: error: arithmetic on po=
inter to
>> an incomplete type
>> drivers/net/ethernet/freescale/fec.c:287:13: error: arithmetic on po=
inter to
>> an incomplete type
>> drivers/net/ethernet/freescale/fec.c:324:7: error: dereferencing poi=
nter to
>> incomplete type
>> etc....
>>
>> These where generated on 3.9-rc1.
>>
>> Can you please fix?
>
> I can fix it.
> I have not build environment to test.
> Can you help me to test it?

Oh yes, I can test any fixes.

If you had a m68k-linux compiler you can build with the
arch/m68k/configs/m5208evb_defconfig which shows the problem.

Regards
Greg



>>   --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
