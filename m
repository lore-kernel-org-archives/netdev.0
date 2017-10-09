From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: avoid zeroing per cpu data again
Date: Mon, 9 Oct 2017 09:41:37 -0700
Message-ID: <20171009164137.pe4f44goul5bzawy@kafai-mbp.dhcp.thefacebook.com>
References: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57554 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754878AbdJIQlo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:41:44 -0400
Content-Disposition: inline
In-Reply-To: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 01:01:37PM +0000, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> per cpu allocations are already zeroed, no need to clear them again.
> 
> Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>
> Cc: Tejun Heo <tj@kernel.org>
Acked-by: Martin KaFai Lau <kafai@fb.com>
