From: Jason Lunz <lunz@falooley.org>
Subject: Re: netif_rx packet dumping
Date: Fri, 4 Mar 2005 19:49:33 +0000 (UTC)
Message-ID: <d0ae4d$s60$1@sea.gmane.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <20050303125556.6850cfe5.davem@davemloft.net> <1109884688.1090.282.camel@jzny.localdomain> <20050303132143.7eef517c@dxpl.pdx.osdl.net> <1109885065.1098.285.camel@jzny.localdomain> <20050303133237.5d64578f.davem@davemloft.net> <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
>> We should eliminate the max backlog thing completely.  There is
>> no need for it.
>
> Still need some bound, because if process_backlog is running slower
> than the net; then the queue could grow till memory exhausted from
> skbuff's. 

yes. I eliminated netdev_max_backlog long ago in an experiment with a
2.4 kernel, and it became quite easy to consume huge amounts of kernel
memory.

Jason
