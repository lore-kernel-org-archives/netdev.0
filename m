From: Cong Wang <amwang@redhat.com>
Subject: Re: [v4 Patch 1/3] netpoll: add generic support for bridge and 	bonding
 devices
Date: Wed, 28 Apr 2010 17:59:03 +0800
Message-ID: <4BD806E7.7010806@redhat.com>
References: <20100427075937.4908.18468.sendpatchset@localhost.localdomain> <j2mce2c83091004272102ye46e65fbod138e63dc58bccd5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Dongdong Deng <libfetion@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <j2mce2c83091004272102ye46e65fbod138e63dc58bccd5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dongdong Deng wrote:
> 
> 
> +             if (ops->ndo_netpoll_cleanup)
> +                                       ops->ndo_netpoll_cleanup(np->dev);
> +             np->dev->npinfo = NULL;
> 
> I think it is good to set np->dev->npinfo to NULL  even though we have
> the netpoll_cleanup opt.
> 

This is redundant, since ->ndo_netpoll_cleanup will set it.

Thanks.
