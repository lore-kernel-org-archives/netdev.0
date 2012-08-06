From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/7] netpoll: use GFP_ATOMIC in slave_enable_netpoll()
 and __netpoll_setup()
Date: Mon, 06 Aug 2012 17:08:38 +0800
Message-ID: <1344244118.14728.28.camel@cr0>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
	 <1343403484-29347-2-git-send-email-amwang@redhat.com>
	 <1343985428.9299.868.camel@edumazet-glaptop> <1343986487.20871.2.camel@cr0>
	 <1343988623.9299.932.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343988623.9299.932.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-03 at 12:10 +0200, Eric Dumazet wrote: 
> 
> I did this , just take it ;)

Do we have to pass gfp to ->ndo_netpoll_setup() too? It seems no, so far
I don't think we have to do that.

Thanks.
