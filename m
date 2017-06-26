From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: conntrack: add a new
 NF_CT_EXT_EXPAND extension
Date: Mon, 26 Jun 2017 19:02:19 +0200
Message-ID: <20170626170219.GA10628@salvia>
References: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
 <20170626165309.GM29636@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lin Zhang <xiaolou4617@gmail.com>, kadlec@blackhole.kfki.hu,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35940 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751544AbdFZRC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 13:02:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6D90BE34FD
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 19:02:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5A8A81B405C
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 19:02:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3548A1B404A
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 19:02:12 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170626165309.GM29636@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 26, 2017 at 06:53:09PM +0200, Florian Westphal wrote:
> Lin Zhang <xiaolou4617@gmail.com> wrote:
> >   In the current conntrack extend code, if we want to add a new
> > extension, we must be add a new extension id and recompile kernel.
> > I think that is not be convenient for users, so i add a new extension named
> > NF_CT_EXT_EXPAND for supporting dynamic register/unregister expansion
> > in runtime that means if kernel support NF_CT_EXT_EXPAND extension,
> > user could call nf_ct_expand_area_add() to register a new expansion
> > but not need to predefine an id in enum nf_ct_ext_id.
> 
> We never did this because its only required for out of tree modules.
> 
> I would prefer if such extensions are discussed/proposed on nf-devel
> instead, and then, if there is agreement that the extension is useful,
> it can be submitted for inclusion in mainline kernel instead.

Indeed. So such extension would receive a bit a public scrutiny.
