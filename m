From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 12:29:14 +0200
Message-ID: <5519257A.2070907@hartkopp.net>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <55191C57.7060906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55191C57.7060906@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.03.2015 11:50, Marc Kleine-Budde wrote:

>>   	can_err_mask_t err_mask;
>> +	struct sk_buff __percpu **uniq_skb;
>> +	ktime_t __percpu *uniq_tstamp;
>
> What about creating a struct to hold the ktime_t and the skb? BTW: the
> pointer to the skb can be marked as const.

Don't think so.

The pointer points to some allocated memory.

Regards,
Oliver

