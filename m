From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 4/5] ipv6: Compute multipath hash for sent ICMP errors from offending packet
Date: Fri, 28 Oct 2016 00:00:14 +0200
Message-ID: <87h97xv4ep.fsf@redhat.com>
References: <20161027.112413.1616222035100737672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20161027.112413.1616222035100737672.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2016 at 03:24 PM GMT, David Miller wrote:
> From: Jakub Sitnicki <jkbs@redhat.com>
> Date: Mon, 24 Oct 2016 11:28:51 +0200
>
>> diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
>> index 57086e9..6282e03 100644
>> --- a/include/linux/icmpv6.h
>> +++ b/include/linux/icmpv6.h
>> @@ -45,4 +45,6 @@ extern void				icmpv6_flow_init(struct sock *sk,
>>  							 const struct in6_addr *saddr,
>>  							 const struct in6_addr *daddr,
>>  							 int oif);
>> +struct ipv6hdr;
>> +extern u32				icmpv6_multipath_hash(const struct ipv6hdr *iph);
>>  #endif
>
> We do not use "extern" in external function declarations in header file any more.

My mistake, will remote it.
