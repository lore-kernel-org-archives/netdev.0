From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is a driver allowed to modify dev->flags?
Date: Tue, 01 Apr 2003 08:58:06 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E89C51E.1060700@candelatech.com>
References: <3e89c32348ce76.94538914@not right>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: rask@sygehus.dk
In-Reply-To: <3e89c32348ce76.94538914@not right>
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> Hi.
> 
> Is a network device driver allowed to modify dev->flags? For example:
> 
> if (dev->flags & IFF_ALLMULTI)
>         dev->flags |= IFF_PROMISC;
> 
> I've found it to cause the IFF_PROMISC flag to stick when using "tcpdump -p", which to my surprice sets the IFF_ALLMULTI flag.
> 
> Regards,
> Rask Ingemann Lambertsen
> 
> 

You are supposed to increment the promisc requestors.  I think something like this:

dev_set_promiscuity(dev, 1);



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


