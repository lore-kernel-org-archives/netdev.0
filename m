From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next v2] can: initial support for network namespaces
Date: Mon, 10 Apr 2017 14:15:08 +0200
Message-ID: <5a15f2ec-4cf4-1d15-f727-1dd666f4cb59@hartkopp.net>
References: <63994a75-c87d-e9d4-f002-afe14127d6a0@kicherer.org>
 <17a0be47-6b8b-1c4f-308b-b09d6f66b86d@hartkopp.net>
 <03c0976c-19ff-0852-835c-fce7c391e15e@kicherer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mario Kicherer <dev@kicherer.org>, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <03c0976c-19ff-0852-835c-fce7c391e15e@kicherer.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Mario,

On 04/10/2017 09:51 AM, Mario Kicherer wrote:

>> You didn't include the statistics here:
>>
>> +       struct s_stats *can_stats;      /* packet statistics */
>> +       struct s_pstats *can_pstats;    /* receive list statistics */
>>
>> which need to be per-net too, right?
>
> I was not sure how this information is used - e.g., maybe just as debug
> information that the system is working. Hence, I just left them as they
> were.

Ok. Completed that now ;-)

>> You do a kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL) in
>> can_pernet_init().
>>
>> Doesn't it need a kfree(net->can.can_rx_alldev_list) then??
>
> Yes, I missed this. Thanks!

I consistently did not remove my new structs too ;-)
Will send a v2 of my 'completion' patch for a review.

> Unfortunately, I don't have access to my CAN hardware right now, hence
> I cannot test a corresponding patch at the moment. :/

Using virtual CANs should be ok for testing.

Best regards,
Oliver
