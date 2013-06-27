From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Thu, 27 Jun 2013 16:21:19 +0800
Message-ID: <51CBF5FF.7090509@asianux.com>
References: <51CB8CB7.6010006@asianux.com> <CAMuHMdVY07PmR-qY-cfgd6X+zHM30oAFMd6oMRZ1NOvXcDS8YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Weinberger <richard@nod.at>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:4203 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab3F0IWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 04:22:12 -0400
In-Reply-To: <CAMuHMdVY07PmR-qY-cfgd6X+zHM30oAFMd6oMRZ1NOvXcDS8YQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 02:48 PM, Geert Uytterhoeven wrote:
> On Thu, Jun 27, 2013 at 2:52 AM, Chen Gang <gang.chen@asianux.com> wr=
ote:
>> > The related driver need depend on HAS_IOMEM, or may be built under=
 UML
>> > architecture.
>> >
>> > The related error (with allmodconfig, without pcap):
>> >
>> >     CC [M]  drivers/ptp/ptp_pch.o
>> >   drivers/ptp/ptp_pch.c: In function =E2=80=98pch_remove=E2=80=99:
>> >   drivers/ptp/ptp_pch.c:571:3: error: implicit declaration of func=
tion =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration=
]
>> >   drivers/ptp/ptp_pch.c: In function =E2=80=98pch_probe=E2=80=99:
>> >   drivers/ptp/ptp_pch.c:621:2: error: implicit declaration of func=
tion =E2=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declaration=
]
>> >   drivers/ptp/ptp_pch.c:621:13: warning: assignment makes pointer =
from integer without a cast [enabled by default]
>> >   cc1: some warnings being treated as errors
>> >
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks.

--=20
Chen Gang
