From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net v2 0/2] ipv4: fix flowi4_iif for input routing
Date: Wed, 16 Apr 2014 08:42:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404160840200.1673@ja.home.ssi.bg>
References: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50216 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751782AbaDPFnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2014 01:43:13 -0400
In-Reply-To: <1397604335-12752-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 15 Apr 2014, Cong Wang wrote:

> This patchset fixes ->flowi4_iif for input routing and rp filter,
> based on suggestion from Julian. See per patch for details.
> 
> v1 -> v2:
> * merge the first two patches into one
> * fix fib_check_nh() too
> * add this cover letter
> 
> Cc: Eric Biederman <ebiederm@xmission.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

	v2 looks good to me, thanks!

Reviewed-by: Julian Anastasov <ja@ssi.bg>

> Cong Wang (2):
>   ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
>   ipv4,route: pass 0 instead of LOOPBACK_IFINDEX to
>     fib_validate_source()
> 
>  include/net/flow.h                | 10 +++++++++-
>  include/net/net_namespace.h       |  9 +--------
>  net/ipv4/fib_frontend.c           |  2 +-
>  net/ipv4/fib_semantics.c          |  1 +
>  net/ipv4/ipmr.c                   |  2 +-
>  net/ipv4/netfilter/ipt_rpfilter.c |  5 +----
>  net/ipv4/route.c                  |  3 +--
>  net/ipv6/ip6mr.c                  |  2 +-
>  8 files changed, 16 insertions(+), 18 deletions(-)
> 
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
