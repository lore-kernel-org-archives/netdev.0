From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] 6lowpan: reassembly: un-export local functions
Date: Thu, 13 Mar 2014 16:10:31 -0400 (EDT)
Message-ID: <20140313.161031.1512355631528238438.davem@davemloft.net>
References: <1394740683-6910-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.aring@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175AbaCMUKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:10:33 -0400
In-Reply-To: <1394740683-6910-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 13 Mar 2014 20:58:03 +0100

> most of these are only used locally, make them static.
> fold lowpan_expire_frag_queue into its caller, its small enough.
> 
> Cc: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Compile tested only.
> 
>  Seems this was cloned off ipv6/reassembly.c which exports
>  some function for ipv6 netfilter defrag, these exports
>  seem to be unneeded for 6lowpan.

Looks like a completely accurate assesment to me, applied.
