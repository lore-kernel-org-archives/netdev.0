From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a
 separate module
Date: Mon, 25 Oct 2010 13:54:39 -0700 (PDT)
Message-ID: <20101025.135439.35034391.davem@davemloft.net>
References: <1287999512.2160.25.camel@este.odu>
	<1288001640.2826.96.camel@edumazet-laptop>
	<4CC5EBC8.9000701@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hidden@balabit.hu, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, bazsi@balabit.hu
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CC5EBC8.9000701@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 25 Oct 2010 22:42:48 +0200

> Am 25.10.2010 12:14, schrieb Eric Dumazet:
>>> netfilter: fix module dependency issues with IPv6 defragmentation, ip6tables and xt_TPROXY
>>>
>>> One of the previous tproxy related patches split IPv6 defragmentation and
>>> connection tracking, but did not correctly add Kconfig stanzas to handle the
>>> new dependencies correctly. This patch fixes that by making the config options
>>> mirror the setup we have for IPv4: a distinct config option for defragmentation
>>> that is automatically selected by both connection tracking and
>>> xt_TPROXY/xt_socket.
>>>
>>> The patch also changes the #ifdefs enclosing IPv6 specific code in xt_socket
>>> and xt_TPROXY: we only compile these in case we have ip6tables support enabled.
>>>
>>> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
>> 
>> Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Dave, please apply directly. Thanks!

Will do, thanks Patrick!
