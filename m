From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c
Date: Tue, 29 Mar 2005 01:16:52 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503290116210.13715@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
 <424819B8.8000201@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <424819B8.8000201@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005, Patrick McHardy wrote:

> Catalin(ux aka Dino) BOIE wrote:
>> Hello!
>> 
>> Trying to load a custom module (same for teql but I didn't tried it)
>> whan the qdisc module is not loaded, makes tc hang.
>> This is because qdisc_create aquires rtnl_sem and then tries to load a 
>> module that tries to register_netdev (that tries to aquire the same 
>> rtnl_sem).
>> Applying this patch makes the problem go away.
>
> You open a race by dropping the lock and not replaying the request
> after acquiring it again. This is Dave's original patch, please
> simply fix this one up so it applies again.
>
> Regards
> Patrick

Patrick,
What to fix in Dave's patch? Seems ok to me.

Thanks!

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
