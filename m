From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netif_poll_disable() hangs
Date: Mon, 08 Sep 2003 18:16:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5CFFD1.6050702@pobox.com>
References: <20030907232145.6ec197fd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20030907232145.6ec197fd.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Very simple:
> 
> 	ifup eth0
> 	ifdown eth0
> 	ifup eth0
> 	ifdown eth0	<- hangs in dev_close -> netif_poll_disable()
> 
> 
> Because the first close sets __LINK_STATE_RX_SCHED and nothing ever clears
> it.  


Thanks, fix patch just sent.
