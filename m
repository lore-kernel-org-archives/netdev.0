From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter fixes for net
Date: Mon, 10 Aug 2015 21:08:46 -0700 (PDT)
Message-ID: <20150810.210846.995750842725656061.davem@davemloft.net>
References: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbbHKEIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:08:47 -0400
In-Reply-To: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 10 Aug 2015 19:58:34 +0200

> The following patchset contains five Netfilter fixes for your net tree,
> they are:
> 
> 1) Silence a warning on falling back to vmalloc(). Since 88eab472ec21, we can
>    easily hit this warning message, that gets users confused. So let's get rid
>    of it.
> 
> 2) Recently when porting the template object allocation on top of kmalloc to
>    fix the netns dependencies between x_tables and conntrack, the error
>    checks where left unchanged. Remove IS_ERR() and check for NULL instead.
>    Patch from Dan Carpenter.
> 
> 3) Don't ignore gfp_flags in the new nf_ct_tmpl_alloc() function, from
>    Joe Stringer.
> 
> 4) Fix a crash due to NULL pointer dereference in ip6t_SYNPROXY, patch from
>    Phil Sutter.
> 
> 5) The sequence number of the Syn+ack that is sent from SYNPROXY to clients is
>    not adjusted through our NAT infrastructure, as a result the client may
>    ignore this TCP packet and TCP flow hangs until the client probes us.  Also
>    from Phil Sutter.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
