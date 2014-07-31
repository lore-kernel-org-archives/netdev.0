From: Ying Xue <ying.xue@windriver.com>
Subject: Re: pull request (net-next): ipsec-next 2014-07-30
Date: Thu, 31 Jul 2014 10:07:58 +0800
Message-ID: <53D9A4FE.4080401@windriver.com>
References: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42893 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbaGaCIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 22:08:37 -0400
In-Reply-To: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

Sorry, it seems you don't include below patch in your pull request:
http://patchwork.ozlabs.org/patch/369818/

Regards,
Ying

On 07/30/2014 07:12 PM, Steffen Klassert wrote:
> This is the last pull request for ipsec-next before I'll be
> off for two weeks starting on friday. David, can you please
> take urgent ipsec patches directly into net/net-next during
> this time?
> 
> 1) Error handling simplifications for vti and vti6.
>    From Mathias Krause.
> 
> 2) Remove a duplicate semicolon after a return statement.
>    From Christoph Paasch.
> 
> Please pull or let me know if there are problems.
> 
> Thanks!
> 
> The following changes since commit 644a918d20336a7deaa81f675c3c2f25bf3dafbb:
> 
>   enic: Make dummy rfs functions inline to fix !CONFIG_RFS_ACCEL build (2014-06-25 18:04:41 -0700)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master
> 
> for you to fetch changes up to 1759389e8af46d724220785bf710b7bdbebdfa48:
> 
>   xfrm4: Remove duplicate semicolon (2014-06-30 07:49:47 +0200)
> 
> ----------------------------------------------------------------
> Christoph Paasch (1):
>       xfrm4: Remove duplicate semicolon
> 
> Mathias Krause (2):
>       vti6: Simplify error handling in module init and exit
>       vti: Simplify error handling in module init and exit
> 
>  net/ipv4/ip_vti.c         | 54 ++++++++++++++++++-----------------------------
>  net/ipv4/xfrm4_protocol.c |  2 +-
>  net/ipv6/ip6_vti.c        | 51 ++++++++++++++++++--------------------------
>  3 files changed, 42 insertions(+), 65 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
