From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netif_rx packet dumping
Date: Tue, 8 Mar 2005 10:09:02 -0800
Message-ID: <20050308100902.24b67b2f.davem@davemloft.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<42278122.6000000@ev-en.org>
	<20050303133659.0d224e61.davem@davemloft.net>
	<42278554.2090902@ev-en.org>
	<20050303135718.2e1a0170.davem@davemloft.net>
	<422DC7CE.2040800@ev-en.org>
	<m1y8cykr7i.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1y8cykr7i.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 08 Mar 2005 18:00:49 +0100
Andi Kleen <ak@muc.de> wrote:

> Baruch Even <baruch@ev-en.org> writes:
> >
> > I can squeeze the tcp_skb_cb to one pointer at the expense of extra
> > work to remove a packet from the list (the other pointer is the prev
> > pointer).
> 
> You could also use a xor list in theory. But I'm not sure it's worth it.
> Increasing cb by 4 bytes shouldn't be a very big issue.

Going from "40" to "44" takes 64-bit platforms onto another cache line
for struct sk_buff, as I stated in another email.

And every time I let this happen, I get an email from David Mosberger because
it shows up in performance tests on ia64. :-)
