From: Andi Kleen <ak@muc.de>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 22:54:24 +0100
Message-ID: <m1fyzc2y5r.fsf@muc.de>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<42278122.6000000@ev-en.org>
	<20050303133659.0d224e61.davem@davemloft.net>
	<42278554.2090902@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <42278554.2090902@ev-en.org> (Baruch Even's message of "Thu, 03
 Mar 2005 21:44:52 +0000")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Baruch Even <baruch@ev-en.org> writes:
>
> If you have a way around this I'd be happy to hear it.

There may be free space left over in skb->cb that you can use
for this.

-Andi
