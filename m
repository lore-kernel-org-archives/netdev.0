From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V3 1/3] can: add can_is_canfd_skb() API
Date: Wed, 05 Nov 2014 18:33:09 +0100
Message-ID: <545A5F55.7050307@hartkopp.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415204533.13896.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415204533.13896.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.11.2014 17:22, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 21:16 +0800, Dong Aisheng wrote:

>
> This looks a bit strange to assume that skb->len == magical_value is CAN
> FD. A comment would be nice.
>

Yes. Due to exactly two types of struct can(fd)_frame which can be contained 
in a skb the skbs are distinguished by the length which can be either CAN_MTU 
or CANFD_MTU.

>> +static inline int can_is_canfd_skb(struct sk_buff *skb)
>
> static inline bool can_is_canfd_skb(const struct sk_buff *skb)
>

ok.

>> +{

What about:

	/* the CAN specific type of skb is identified by its data length */

>> +	return skb->len == CANFD_MTU;
>> +}
>> +
>>   /* get data length from can_dlc with sanitized can_dlc */
>>   u8 can_dlc2len(u8 can_dlc);

Regards,
Oliver

