From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] acenic - don't spin in hard_start_xmit when ring fills
Date: Fri, 17 Sep 2004 11:31:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917113147.342eef72.davem@davemloft.net>
References: <20040916161753.37254cbd@dell_ss3.pdx.osdl.net>
	<20040916162250.5b7cfa85.davem@davemloft.net>
	<20040916164206.707204d4@dell_ss3.pdx.osdl.net>
	<20040916165042.362a3e79.davem@davemloft.net>
	<20040917090217.43483d10@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040917090217.43483d10@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Sep 2004 09:02:17 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Thu, 16 Sep 2004 16:50:42 -0700
> "David S. Miller" <davem@davemloft.net> wrote:
> 
> > 1) Accept this spinning performance characteristic of the
> >    acenic driver.
> 
> What if there is buggy, hardware that never drains the ring.
> It can happen.

You're preaching to the choir :-)  I've been bugging Alexey about
this aspect of the Acenic driver since day one.

> > 2) Finally give up on acenic's clever lockless scheme and add
> >    the necessary locking + start/stop tx flow control so it
> >    will never have to return TX_BUSY except in absolutely
> >    catastrophic failure cases.
> 
> I'll code up a non-lockless version and see if makes any real difference.

Let me know how it goes.
