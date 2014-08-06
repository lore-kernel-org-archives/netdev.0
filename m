From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: reallocate new socket option number for
 IPV6_AUTOFLOWLABEL
Date: Thu, 7 Aug 2014 00:15:42 +0200
Message-ID: <20140806221542.GA3645@salvia>
References: <1407363050-3573-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	davej@redhat.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407363050-3573-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 07, 2014 at 12:10:50AM +0200, Pablo Neira Ayuso wrote:
> cb1ce2e ("ipv6: Implement automatic flow label generation on transmit")
> accidentally uses socket option 64, which is already used by ip6tables:
> 
>  IP6T_SO_SET_REPLACE / IP6T_SO_GET_INFO               64
>  IP6T_SO_SET_ADD_COUNTERS / IP6T_SO_GET_ENTRIES       65
> 
> There is comment include/uapi/linux/in6.h warning about that.

Wrong patch, 68 is also used.

Sending a v2.
