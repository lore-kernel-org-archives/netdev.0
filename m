From: Zhi Li <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch net-next 04/11] net:fec: add multiqueue support
Date: Wed, 3 Sep 2014 22:41:37 -0500
Message-ID: <CAHrpEqRSGg9=B8nk-PFkayP1kN8eQ5UnBvjikR5svub-wD-d6w@mail.gmail.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
	<1409776697-1536-5-git-send-email-Frank.Li@freescale.com>
	<540787B9.8090504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Duan Fugang-B38611 <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <540787B9.8090504-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 3, 2014 at 4:27 PM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 09/03/2014 01:38 PM, Frank Li wrote:
>> From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>
>> Add multiqueue support, which is compatible with previous single queue
>> driver for FEC/ENET IPs.
>>
>> By default, the tx/rx queue number is 1, user can config the queue number
>> at DTS file like this:
>>       fsl,num_tx_queues=<3>;
>>       fsl,num_rx_queues=<3>;
>>
>> Ethernet multiqueue mechanism can improve performance in SMP system.
>> For single hw queue, multiqueue can balance cpu loading.
>> For multi hw queues, multiple cores can process network packets in parallel,
>> and refer the article for the detail advantage for multiqueue:
>> http://vger.kernel.org/~davem/davem_nyc09.pdf
>
> You should probably split that patch in a minimum of two, or more
> different parts.
>
> Two parts:
>
> - add TX multiqueue support
> - add RX multiqueue support
>

I understood your concern.
We also need consider logical integration.

Separate this patch just reduce changed lines in a patch.
Most of this patch change is from fep-> to txq-> or rxq->

best regards
Frank Li

> More parts:
>
> - prepare for TX multiqueue (introduce queue structure, definitions)
> - transition TX path to use queue 0
> - add support for the two other TX queues
> - prepare for RX multiqueue (introduce queue structure, definitions)
> - prepare for multiqueue, hardcode RX path to use queue 0
> - add support for the two other RX queues
>
> The number of changes are extremely hard to review...
> --
> Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
