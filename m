From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed, 7 Jun 2017 22:00:43 -0700
Message-ID: <20170608050041.cte3gpavshg2nmdc@ast-mbp>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170608043847.uejvydlitzuik76j@ast-mbp>
 <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "=David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36046 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751035AbdFHFAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 01:00:47 -0400
Received: by mail-pf0-f196.google.com with SMTP id y7so3768483pfd.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 22:00:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 12:56:58PM +0800, 严海双 wrote:
> 
> > On 8 Jun 2017, at 12:38 PM, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > 
> > On Thu, Jun 08, 2017 at 12:32:44PM +0800, Haishuang Yan wrote:
> >> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
> >> dst_release to free it in error code path.
> >> 
> >> CC: Alexei Starovoitov <ast@fb.com>
> >> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> >> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> > 
> > I don't get it. Why did you send another version of the patch?
> > What was wrong with previous approach that myself and Eric acked?
> > 
> > 
> 
> Sorry for your confusing, because Pravin Shelar give a feedback in ipv4 patch, see below:

hmm. right.
Then it raises the question: How did you test this and previous patch?

since previous version was sort-of fixing the bug, but completely
breaking the logic...
