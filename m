From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: Fri, 11 Mar 2005 15:15:58 +0100
Message-ID: <20050311141558.GG31837@postel.suug.ch>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net> <1110481248.1074.306.camel@jzny.localdomain> <Pine.LNX.4.62.0503110859570.11178@webhosting.rdsbv.ro> <20050311132848.GF31837@postel.suug.ch> <1110549556.2127.14.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Catalin(ux aka Dino)   BOIE" <util@deuroconsult.ro>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110549556.2127.14.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1110549556.2127.14.camel@jzny.localdomain> 2005-03-11 08:59
> As an alternative:
> we can probably still keep the user space interface the way he has it
> and just underneath hide it as meta ematch? This will mean no script
> changes - but if it is too much work to hide it, it may not be worth it.

The only problem is what to do when both the existing u32 mark and a
ematch tree is given. We can probably push it at the beginning of the
tree with a AND relation so it should work out correctly. Sounds like
a good idea and shouldn't be too much work.
