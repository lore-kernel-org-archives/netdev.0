From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed, 7 Jun 2017 21:38:49 -0700
Message-ID: <20170608043847.uejvydlitzuik76j@ast-mbp>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "=David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36254 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdFHEiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 00:38:52 -0400
Received: by mail-pf0-f176.google.com with SMTP id x63so12756840pff.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 21:38:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 12:32:44PM +0800, Haishuang Yan wrote:
> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
> dst_release to free it in error code path.
> 
> CC: Alexei Starovoitov <ast@fb.com>
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

I don't get it. Why did you send another version of the patch?
What was wrong with previous approach that myself and Eric acked?
