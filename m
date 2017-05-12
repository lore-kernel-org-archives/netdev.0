From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: Truncate single route when it doesn't fit into
 dump buffer.
Date: Fri, 12 May 2017 10:26:08 -0700
Message-ID: <3828cf04-1bf8-92d2-dfc4-184bd615fe10@gmail.com>
References: <20170512111510.2697-1-mq@ucw.cz>
 <20170512.112447.1421545301592945998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, mq@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512.112447.1421545301592945998.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/12/17 8:24 AM, David Miller wrote:
> From: Jan Moskyto Matejka <mq@ucw.cz>
> Date: Fri, 12 May 2017 13:15:10 +0200
> 
>> -int rt6_dump_route(struct rt6_info *rt, void *p_arg);
>> +int rt6_dump_route(struct rt6_info *rt, void *p_arg, int truncate);
> 
> Please use "bool" and "true"/"false" for boolean values.
> 
> What does ipv4 do in this situation?
> 
> I'm hesitant to be OK with adding a new nlmsg flag just for this case
> if we solve this problem differently and using existing mechanisms
> elsewhere.
> 

I'll take a look at this later today or this weekend; we can't just
truncate the route returned to userspace.
