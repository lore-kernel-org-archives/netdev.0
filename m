From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Sun, 20 Jul 2008 20:34:18 +0300
Message-ID: <1ba2fa240807201034u1fbe3343tdcc858f7772d2b39@mail.gmail.com>
References: <1216387641.4833.96.camel@localhost>
	 <20080718.140539.122169028.davem@davemloft.net>
	 <1216566963.4847.81.camel@localhost>
	 <20080720.102534.246150854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080720.102534.246150854.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 20, 2008 at 8:25 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
> Date: Sun, 20 Jul 2008 11:16:03 -0400
>
>> IMO, in the case of multiple hardware queues per physical wire,
>> and such a netdevice already has a built-in hardware scheduler (they all
>> seem to have this feature) then if we can feed the hardware queues
>> directly, theres no need for any intermediate buffer(s).
>> In such a case, to compare with qdisc arch, its like the root qdisc is
>> in hardware.
>
> They tend to implement round-robin or some similar fairness algorithm
> amongst the queues, with zero concern about packet priorities.
>
> It really is just like a bunch of queues to the phsyical layer,
> fairly shared.
>
> These things are built for parallelization, not prioritization.

Except wireless where HW has prioritizing scheduler per physical non-wire.
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
