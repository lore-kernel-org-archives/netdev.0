From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 14:04:29 -0800
Message-ID: <20050303140429.1aac962e.davem@davemloft.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<42278122.6000000@ev-en.org>
	<20050303133659.0d224e61.davem@davemloft.net>
	<42278554.2090902@ev-en.org>
	<m1fyzc2y5r.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1fyzc2y5r.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Mar 2005 22:54:24 +0100
Andi Kleen <ak@muc.de> wrote:

> Baruch Even <baruch@ev-en.org> writes:
> >
> > If you have a way around this I'd be happy to hear it.
> 
> There may be free space left over in skb->cb that you can use
> for this.

There is 4 bytes, enough for 32-bit but not 64-bit platforms.
Also, see my other reply to his posting.
