From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: gre: Use the consitent GRE and PPTP
 struct instead of the structures defined in netfilter
Date: Thu, 25 Aug 2016 14:16:50 +0200
Message-ID: <20160825121650.GA2537@salvia>
References: <1471618894-10582-1-git-send-email-fgao@ikuai8.com>
 <CA+6hz4piLVv=L03sst56GrOWMST6gTvEF7h4i1jGw0fNw0M8jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com>, Patrick McHardy <kaber@trash.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45412 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933845AbcHYMRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:17:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 19648FEFB8
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:16:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1127EFC61E
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:16:59 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1A163100A75
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:16:55 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CA+6hz4piLVv=L03sst56GrOWMST6gTvEF7h4i1jGw0fNw0M8jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:03:46PM +0800, Feng Gao wrote:
> My email server reports the last same patch email failed to send.
> So I just sent it again.
> 
> I am sorry, if anyone receives duplicated ones.

git am v2-1-2-net-next-netfilter-gre-Use-consistent-GRE_-macros-instead-of-ones-defined-by-netfilter..patch
-s
Applying: netfilter: gre: Use consistent GRE_* macros instead of ones
defined by netfilter.
error: patch failed: include/uapi/linux/if_tunnel.h:36
error: include/uapi/linux/if_tunnel.h: patch does not apply

It seems your base was missing this patch:

commit ab10dccb11608b96b43b557c12a5ad867723e503
Author: Gao Feng <fgao@ikuai8.com>
Date:   Tue Aug 9 12:38:24 2016 +0800

    rps: Inspect PPTP encapsulated by GRE to get flow hash

Since I cannot see GRE_FLAGS in your patch as context.

Please rebase and resubmit, thanks!
