From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix outstanding ref's preventing ether driver unload
Date: Tue, 23 Dec 2003 15:25:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031223152540.3f0f6f49.davem@redhat.com>
References: <OFB4EC53DF.8138874D-ON88256DF9.0082A560@us.ibm.com>
	<20031223142931.703d5c88.shemminger@osdl.org>
	<20031223143832.5fe65329.davem@redhat.com>
	<20031223151154.01fd002a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031223151154.01fd002a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Dec 2003 15:11:54 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Tue, 23 Dec 2003 14:38:32 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > Are you going to add such code to RAW, UDP, TCP, etc. etc.?
> 
> They don't have the problem because they don't go through the netdev_queue_xmit_nit
> code path.  Audited all calls to dev_add_packet and AF_PACKET is the only
> one that I found that could potentially register for ptype_all.
> 
> The same thing could happen through the loopback device, though.
> But the loopback device can never be unloaded so it doesn't really
> hurt anything.

I see, thanks for the clarification.... I have an idea, let me think
about this a little bit more.
