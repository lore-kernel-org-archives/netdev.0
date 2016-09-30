From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v4 1/2] netfilter: Fix potential null pointer
 dereference
Date: Fri, 30 Sep 2016 19:41:52 +0200
Message-ID: <20160930174152.GC1176@salvia>
References: <1475076915-5920-1-git-send-email-aconole@bytheb.org>
 <1475076915-5920-2-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:56532 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932430AbcI3SFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 14:05:47 -0400
Content-Disposition: inline
In-Reply-To: <1475076915-5920-2-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 11:35:14AM -0400, Aaron Conole wrote:
> It's possible for nf_hook_entry_head to return NULL.  If two
> nf_unregister_net_hook calls happen simultaneously with a single hook
> entry in the list, both will enter the nf_hook_mutex critical section.
> The first will successfully delete the head, but the second will see
> this NULL pointer and attempt to dereference.
> 
> This fix ensures that no null pointer dereference could occur when such
> a condition happens.

Applied, thanks Aaron.
