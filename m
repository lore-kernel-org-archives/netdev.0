From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] pktgen handle netdev device getting full.
Date: Thu, 16 Sep 2004 15:59:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916155913.577b878b.davem@davemloft.net>
References: <20040916144332.37f19fcb@dell_ss3.pdx.osdl.net>
	<414A1AD2.1090109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, Robert.Olsson@data.slu.se, davem@redhat.com,
        netdev@oss.sgi.com, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <414A1AD2.1090109@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 15:59:30 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > I was trying out pktgen on a NIC with an undersized ring, so 
> > hard_start_xmit would always return non-zero when full.  This caused a slew
> > of console messages.  Better to just have pktgen retry in this case.
> 
> My understanding is that if the queue is not stopped, then you
> should not get the hard xmit errors.  So, in a proper driver,
> you should not see these printks.

That is absolutely correct, that is why Stephen's patch is
not correct (aside from the do_div() part which I'll happily
apply if submitted by itself).

> By the way, is there any interest in adding my patch that also allows
> pktgen to receive packets (and count the statistics, etc)?  I know
> DaveM objected to the hook in the skb-receive logic some time back,
> but maybe he has a different opinion now?

I still object to this, it will be abused.
