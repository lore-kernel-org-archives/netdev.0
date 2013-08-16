From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH v4 4/5] ARM: davinci: da850: add DT node for eth0.
Date: Fri, 16 Aug 2013 09:37:31 +0530
Message-ID: <CA+V-a8tDUE8Ni2CbJchA0rnTY3OijBuLK6L=OtH_FDXupOn9tg@mail.gmail.com>
References: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
 <1376546497-26931-5-git-send-email-prabhakar.csengg@gmail.com> <520D2C50.4040902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sekhar Nori <nsekhar@ti.com>,
	DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	device-tree <devicetree-discuss@lists.ozlabs.org>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520D2C50.4040902@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Fri, Aug 16, 2013 at 1:00 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 15-08-2013 10:01, Lad, Prabhakar wrote:
>
>> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>
>
>> Add eth0 device tree node information and pinmux for mii to da850 by
>> providing interrupt details and local mac address of eth0.
>
>
>> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>
> [...]
>
>
>> @@ -226,6 +242,20 @@
>>                         #size-cells = <0>;
>>                         reg = <0x224000 0x1000>;
>>                 };
>> +               eth0: emac@1e20000 {
>
>
>    According to the ePAPR spec[1] section 2.2.2, the node should be named
> "ethernet".
>
Thanks for pointing it, I'll fix and repost it.

Regards,
--Prabhakar Lad

> [1] http://www.power.org/resources/downloads/Power_ePAPR_APPROVED_v1.0.pdf
>
> WBR, Sergei
>
