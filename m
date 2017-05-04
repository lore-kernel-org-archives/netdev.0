From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 14:15:48 -0500
Message-ID: <20170504141548.Horde.VjUEZJdTZiLesC8PBMAO8QM@gator4166.hostgator.com>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
 <20170504.124600.627647229351638856.davem@davemloft.net>
 <1493920071.22125.37.camel@perches.com>
 <20170504140015.Horde.iqqsROVYuFdJnC6P1dMPyBa@gator4166.hostgator.com>
 <1493924538.22125.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493924538.22125.43.camel@perches.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Joe Perches <joe@perches.com>:

> On Thu, 2017-05-04 at 14:00 -0500, Gustavo A. R. Silva wrote:
>> Regarding the code comments, what about the following patch:
> []
>> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> []
>> @@ -389,6 +389,12 @@ static int sk_diag_fill(struct sock *sk, struct
>> sk_buff *skb,
>>                                    nlmsg_flags, unlh, net_admin);
>>   }
>>
>> +/*
>> + * Ignore the position of the arguments req->id.idiag_dport and
>> + * req->id.idiag_sport in both calls to inet_lookup() and inet6_lookup()
>> + * functions, once this is a locked in behavior exposed to user space.
>> + * Changing this will break things for people.
>> + */
>>   struct sock *inet_diag_find_one_icsk(struct net *net,
>>                                       struct inet_hashinfo *hashinfo,
>>                                       const struct inet_diag_req_v2 *req)
>>
>
> Seems sensible.  Thanks.

Should I resend it in a full and proper format or it can taken from here?

Thanks
--
Gustavo A. R. Silva
