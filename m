From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 07 Jun 2004 19:38:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086651524.1037.10.camel@jzny.localdomain>
References: <200406062128.47070.vkondra@mail.ru>
	 <20040607140011.GC28639@wotan.suse.de> <200406072335.04125.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406072335.04125.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 2004-06-07 at 16:35, Vladimir Kondratiev wrote:
> How could I use these multiple qdiscs? If I use existing driver framework, I 
> have hard_start_xmit, that represent single queue. Do you have any examples 
> how driver can access qdiscs directly? I.e. I have 4 queues in the driver, I 
> want to fill it separately, start/stop incoming queues from stack etc.

Maybe you can explain a little more: Do these 4 queues translate to 4
DMA rings or channles on the NIC? Could you not use a tag like fwmark to
select DMA to send to? 
Explain the packet path once it hits the driver.

> Note also, we are talking about 100Mbps above MAC, which translates to about 
> 150 Mbps, within next 2 years. 100Mbps above MAC is criteria for TGn working 
> group in IEEE (high throughput).

Are these wireless NICs? Whats the big deal about 150Mbps?

cheers,
jamal
