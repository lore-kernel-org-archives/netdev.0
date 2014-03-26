From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v5] netlink: have netlink per-protocol bind function
 return an error code.
Date: Wed, 26 Mar 2014 15:52:58 -0400 (EDT)
Message-ID: <20140326.155258.685120737486107362.davem@davemloft.net>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
	<5bf7c2b8ad25b31bb34ae00f5fe6ec7f5d653f4b.1395693533.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: rgb@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5bf7c2b8ad25b31bb34ae00f5fe6ec7f5d653f4b.1395693533.git.rgb@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Mon, 24 Mar 2014 16:59:23 -0400

> +				if (err)
> +					if (!nlk->portid)
> +						netlink_remove(sk);
> +					for (int undo = 0; undo < i; undo++)
> +						if (nlk->netlink_unbind)
> +							nlk->netlink_unbind(undo);
> +					return err;

Take a good long stare at that code block for a while.

Looks like you forgot the braces to delineate the code block.

This also means you really haven't tested this patch :-)

Please also DO NOT declare local variables in a for() statement,
this is not c++.
