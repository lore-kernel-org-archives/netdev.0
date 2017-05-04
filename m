From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 14:24:32 -0500
Message-ID: <20170504142432.Horde.g9y26Ryxbtg1EIl_cnsdbbw@gator4166.hostgator.com>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
 <20170504.124600.627647229351638856.davem@davemloft.net>
 <1493920071.22125.37.camel@perches.com>
 <20170504140015.Horde.iqqsROVYuFdJnC6P1dMPyBa@gator4166.hostgator.com>
 <1493924538.22125.43.camel@perches.com>
 <20170504141548.Horde.VjUEZJdTZiLesC8PBMAO8QM@gator4166.hostgator.com>
 <1493925433.31950.0.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493925433.31950.0.camel@perches.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Quoting Joe Perches <joe@perches.com>:

[]
>> > > +/*
>> > > + * Ignore the position of the arguments req->id.idiag_dport and
>> > > + * req->id.idiag_sport in both calls to inet_lookup() and  
>> inet6_lookup()
>> > > + * functions, once this is a locked in behavior exposed to user space.
>> > > + * Changing this will break things for people.
>> > > + */
>> > >   struct sock *inet_diag_find_one_icsk(struct net *net,
>> > >                                       struct inet_hashinfo *hashinfo,
>> > >                                       const struct  
>> inet_diag_req_v2 *req)
>> > >
>> >
>> > Seems sensible.  Thanks.
>>
>> Should I resend it in a full and proper format or it can taken from here?
>
> If you want it applied, it should be resent as a full patch
> with your sign-off.

I'll send it shortly.

Thanks for clarifying
--
Gustavo A. R. Silva
