From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: 11 Mar 2005 08:59:16 -0500
Message-ID: <1110549556.2127.14.camel@jzny.localdomain>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net>
	 <1110481248.1074.306.camel@jzny.localdomain>
	 <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro>
	 <20050311132848.GF31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Catalin(ux aka Dino)  "BOIE <util@deuroconsult.ro>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050311132848.GF31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-11 at 08:28, Thomas Graf wrote:
> * Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro> 2005-03-11 09:01

> > 
> > It can die, but there are users that use it.
> > So, I think that as long as u32 will stay in kernel, we can let 
> > mark_in_u32 live.
> > It's a small modification and I think it may stay.
> 
> Everyone told you that it would only be a temporary solution and once
> the meta ematch works flawlessly there is no reason to keep it in the
> tree. In order to give everyone enough time to switch the removal should
> be announced on LARTC mailinglist and commited 2-3 release cycles later.
> 

As an alternative:
we can probably still keep the user space interface the way he has it
and just underneath hide it as meta ematch? This will mean no script
changes - but if it is too much work to hide it, it may not be worth it.

cheers,
jamal
