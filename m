From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: Fri, 11 Mar 2005 16:05:47 +0200 (EET)
Message-ID: <Pine.LNX.4.62.0503111556090.11178@webhosting.rdsbv.ro>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net>
 <1110481248.1074.306.camel@jzny.localdomain> <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro>
 <20050311132848.GF31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jamal Hadi Salim <hadi@znyx.com>, Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050311132848.GF31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> It can die, but there are users that use it.
>> So, I think that as long as u32 will stay in kernel, we can let
>> mark_in_u32 live.
>> It's a small modification and I think it may stay.
>
> Everyone told you that it would only be a temporary solution and once
> the meta ematch works flawlessly there is no reason to keep it in the
> tree. In order to give everyone enough time to switch the removal should
> be announced on LARTC mailinglist and commited 2-3 release cycles later.

Yes, you are right, everybody told me. I don't deny.
And I will respect the decision that will be taken.
But I'm wonder what are the gains removing nfmark from u32?
~64 bytes of code and 128 bytes of sources?!
I thing that the gain being in is bigger than the gains resulting from 
removing it.

I will not ask another set of questions. If I'm wrong, let me know and I 
will send, as soon as I can, patches to remove it from kernel (with 3 
releases warning).

Thank you for your time!

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
