From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: Fri, 11 Mar 2005 14:28:48 +0100
Message-ID: <20050311132848.GF31837@postel.suug.ch>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net> <1110481248.1074.306.camel@jzny.localdomain> <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@znyx.com>, Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro> 2005-03-11 09:01
> On Thu, 10 Mar 2005, Jamal Hadi Salim wrote:
> 
> >
> >Agreed on both counts.
> >
> >Note, however, the tc_u32_mark should die Real Soon Now given the
> >meta match patches that are in from Thomas.
> 
> It can die, but there are users that use it.
> So, I think that as long as u32 will stay in kernel, we can let 
> mark_in_u32 live.
> It's a small modification and I think it may stay.

Everyone told you that it would only be a temporary solution and once
the meta ematch works flawlessly there is no reason to keep it in the
tree. In order to give everyone enough time to switch the removal should
be announced on LARTC mailinglist and commited 2-3 release cycles later.
