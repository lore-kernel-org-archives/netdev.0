From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 15:37:46 -0400
Message-ID: <1119469066.6918.168.camel@localhost.localdomain>
References: <42A5284C.3060808@osdl.org>
	 <1118147904.6320.108.camel@localhost.localdomain>
	 <Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>
	 <20050621.133704.08321534.davem@davemloft.net>
	 <42B92490.40005@draigBrady.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, gandalf@wlug.westbo.se,
        shemminger@osdl.org, mitch.a.williams@intel.com,
        john.ronciak@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <42B92490.40005@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-22-06 at 09:42 +0100, P@draigBrady.com wrote:

> 
> Yes the copy is essentially free here as the data is already cached.
> 
> As a data point, I went the whole hog and used buffer recycling
> in my essentially packet sniffing application. I.E. there are no
> allocs per packet at all, and this make a HUGE difference. On a
> 2x3.4GHz 2xe1000 system I can receive 620Kpps per port sustained
> into my userspace app which does a LOT of processing per packet.
> Without the buffer recycling is was around 250Kpps.
> Note I don't reuse an skb until the packet is copied into a
> PACKET_MMAP buffer.

Was this machine SMP? NAPI involved? I take it nothing interfering in
the middle with the headers?

cheers,
jamal
