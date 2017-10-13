From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: check fn before doing FIB6_SUBTREE(fn)
Date: Fri, 13 Oct 2017 15:49:58 -0700
Message-ID: <20171013224949.mrl6jsy6uj22kl2e@kafai-mbp.dhcp.thefacebook.com>
References: <20171013220108.88710-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38498 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751339AbdJMWuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 18:50:04 -0400
Content-Disposition: inline
In-Reply-To: <20171013220108.88710-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 10:01:08PM +0000, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> In fib6_locate(), we need to first make sure fn is not NULL before doing
> FIB6_SUBTREE(fn) to avoid crash.
Acked-by: Martin KaFai Lau <kafai@fb.com>
