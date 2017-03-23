From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: NULL timer crash
Date: Thu, 23 Mar 2017 12:32:28 -0700
Message-ID: <1490297548.9687.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+Yb9BvzcRT84EriUCqx6hnz_kciYNHjHNX56y1jDb70vw@mail.gmail.com>
         <CANn89i+_+da3PBYjk-KwcUpa6qr0MdqVXOmrsQUM7_VzgBurnA@mail.gmail.com>
         <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170323.120035.1924712018254677829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, xiyou.wangcong@gmail.com,
        herbert@gondor.apana.org.au, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323.120035.1924712018254677829.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-23 at 12:00 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 23 Mar 2017 09:00:58 -0700
> 
> > On Thu, 2017-03-23 at 07:53 -0700, Eric Dumazet wrote:
> > 
> >> Nice !
> >> 
> >> Looks like neigh->ops->solicit is NULL
> > 
> > Apparently we allow admins to do really stupid things with neighbours
> > on tunnels.
> > 
> > Following patch should avoid the crash.
> > 
> > Anyone has better ideas ?
> 
> This is probably good enough for now, but you need to also handle
> dn_neigh_ops.
> 
> Another way to solve this is to add a NULL method check to the
> one spot where we invoke this method.  That clearly shows that
> the method is optional.

Yes, this would be a one liner. I will post this in a minute.

Thanks.
