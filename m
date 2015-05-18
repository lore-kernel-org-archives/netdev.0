From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: Use correct return for seq_show
 functions
Date: Mon, 18 May 2015 17:57:38 +0200
Message-ID: <20150518155738.GA3854@salvia>
References: <1431480503.2884.110.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38093 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbbERPw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 11:52:56 -0400
Content-Disposition: inline
In-Reply-To: <1431480503.2884.110.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 06:28:23PM -0700, Joe Perches wrote:
> Using seq_has_overflowed doesn't produce the right return value.
> Either 0 or -1 is, but 0 is much more common and works well when
> seq allocation retries.
> 
> I believe this doesn't matter as the initial allocation is always
> sufficient, this is just a correctness patch.
> 
> Miscellanea:
> 
> o Don't use strlen, use *ptr to determine if a string
>   should be emitted like all the other tests here
> o Delete unnecessary return statements

Applied, thanks.
