From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: problem with IPoA (CLIP), NAT, and VLANS
Date: Wed, 18 Feb 2009 23:31:45 -0800 (PST)
Message-ID: <20090218.233145.66997963.davem@davemloft.net>
References: <20090216232016.GA4803@ami.dom.local>
	<499A7D7D.1090607@trash.net>
	<20090217093908.GB5341@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, karl@hiramoto.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, linux-kernel@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090217093908.GB5341@ff.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 17 Feb 2009 09:39:08 +0000

> vlan: Update skb->mac_header in __vlan_put_tag().
> 
> After moving mac addresses in __vlan_put_tag() skb->mac_header needs
> to be updated.
> 
> Reported-by: Karl Hiramoto <karl@hiramoto.org>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Patch applied, this is correct even though it doesn't fix the bug.

I'm pretty sure that packet corruption is a driver error of
some kind rather than some kind of generic problem.
