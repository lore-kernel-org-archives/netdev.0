From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v4 2/2] nf_set_hooks_head: accommodate different
 kconfig
Date: Fri, 30 Sep 2016 19:43:16 +0200
Message-ID: <20160930174316.GD1176@salvia>
References: <1475076915-5920-1-git-send-email-aconole@bytheb.org>
 <1475076915-5920-3-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59962 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933039AbcI3Rn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:43:29 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2D3EAE3A0A
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 19:43:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1B1E0BAC24
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 19:43:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id EFFB2BAC28
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 19:43:23 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1475076915-5920-3-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 11:35:15AM -0400, Aaron Conole wrote:
> When CONFIG_NETFILTER_INGRESS is unset (or no), we need to handle
> the request for registration properly by dropping the hook.  This
> releases the entry during the set.

Also applied.

I have renamed the subject to:

        netfilter: accommodate different kconfig in nf_set_hooks_head()

to make it look similar to what we have in the history.

Thanks.
