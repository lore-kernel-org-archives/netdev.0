From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Tue, 6 Dec 2016 00:05:25 +0100
Message-ID: <20161205230524.GA15645@salvia>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc>
 <20161205223415.GA14689@salvia>
 <20161205224051.GB16819@breakpoint.cc>
 <1480978749.18162.561.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59738 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751320AbcLEXFh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 18:05:37 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0C5228CD65
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:05:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F26E0A7E27
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:05:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 07511A7E25
        for <netdev@vger.kernel.org>; Tue,  6 Dec 2016 00:05:34 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1480978749.18162.561.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 02:59:09PM -0800, Eric Dumazet wrote:
> On Mon, 2016-12-05 at 23:40 +0100, Florian Westphal wrote:
> 
> > Fair enough, I have no objections to the patch.
> 
> An additional question is about PATH_MAX :
> 
> Is it guaranteed to stay at 4096 forever ?
> 
> To be safe, maybe we should use a constant of our own.

Right, this reminds me we have to fix something else.

So constant of our own plus something smaller, if possible, would be
good to go. Thanks.
