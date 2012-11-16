From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter updates for nf-next (try 2)
Date: Fri, 16 Nov 2012 13:00:44 -0500 (EST)
Message-ID: <20121116.130044.936556420105398924.davem@davemloft.net>
References: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 16 Nov 2012 13:40:49 +0100

> This is the second try to include the following four patches that contain
> updates for your net-next tree, they are:
> 
> * Little cleanup for IPVS the use of a strange notation to assign the
>   conntrack object, from Alan Cox.
> 
> * Another little cleanup for nf_nat to save a couple of lines by using
>   PTR_RET, from Wu Fengguan
> 
> * getsockopt support to obtain the original IPv6 address after NAT,
>   similar to the one that IPv4 provides, from Florian Westphal.
> 
> * Follow-up patch pointed out by YOSHIFUJI Hideaki to only provide
>   the scope_id in case that link is local, again from Florian Westphal.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Pulled, thanks.

There was a conflict I had to resolve because the net-next tree
had a series of IS_ENABLED conversions that overlapped with some
of the changes in your tree.
