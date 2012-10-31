From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter updates for the net tree
Date: Wed, 31 Oct 2012 14:57:17 -0400 (EDT)
Message-ID: <20121031.145717.1393377293605160832.davem@davemloft.net>
References: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue, 30 Oct 2012 11:19:17 +0100

> The following patchset contains fixes for your net tree, two of them
> are due to relatively recent changes, one has been a longstanding bug,
> they are:
> 
> * Fix incorrect usage of rt_gateway in the H.323 helper, from
>   Julian Anastasov.
> 
> * Skip re-route in nf_nat code for ICMP traffic. If CONFIG_XFRM is
>   enabled, we waste cycles to look up for the route again. This problem
>   seems to be there since really long time. From Ulrich Weber.
> 
> * Fix mismatching section in nf_conntrack_reasm, from Hein Tibosch.
> 
> You can pull this changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks.
