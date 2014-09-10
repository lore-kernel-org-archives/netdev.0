From: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch v2 net-next 09/12] net: fec: change FEC alignment
 according to i.mx6 sx requirement
Date: Wed, 10 Sep 2014 10:27:51 -0300
Message-ID: <CAOMZO5AFUKeKpPrOzVe+GqhSzF0Hg2dK3HPf4X+4r0G-EH2iZA@mail.gmail.com>
References: <1410293743-27874-1-git-send-email-Frank.Li@freescale.com>
	<1410293743-27874-10-git-send-email-Frank.Li@freescale.com>
	<CAOMZO5AwOWr8uWCvt3XzM8CJideu+1LBY6QUQ772QjLjCYxL1w@mail.gmail.com>
	<CAHrpEqSf8j7NUZDAORYwN4cbd2MBA9bcKa9mzNGg4JJiKsJKvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Duan Fugang-B38611 <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zhi Li <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHrpEqSf8j7NUZDAORYwN4cbd2MBA9bcKa9mzNGg4JJiKsJKvA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 10:22 AM, Zhi Li <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Sep 10, 2014 at 7:51 AM, Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Tue, Sep 9, 2014 at 5:15 PM, Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org> wrote:
>>
>>> +       fep->rx_align = 0x3;
>>> +       fep->tx_align = 0x3;
>>
>> Why do you unconditionally set it as 0x3? It was 0xf for ARM and 0x3
>> for non-ARM.
>
> Will fix it at next version.

Also, please make sure to add Russell King on Cc in the next version.
He has recently done a lot of work in this driver.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
