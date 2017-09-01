From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net 1/2] Revert "net: use lib/percpu_counter API for
 fragmentation mem accounting"
Date: Fri, 1 Sep 2017 11:30:30 +0200
Message-ID: <20170901093030.GA951@breakpoint.cc>
References: <150425790711.22227.12264977619066874632.stgit@firesoul>
 <150425796850.22227.6149901788992481211.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:44882 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751595AbdIAJdS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:33:18 -0400
Content-Disposition: inline
In-Reply-To: <150425796850.22227.6149901788992481211.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> This reverts commit 6d7b857d541ecd1d9bd997c97242d4ef94b19de2.
> 
> There is a bug in fragmentation codes use of the percpu_counter API,
> that can cause issues on systems with many CPUs.

Acked-by: Florian Westphal <fw@strlen.de>

Thanks Jesper.
