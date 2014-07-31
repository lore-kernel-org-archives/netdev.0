From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: fix releasing uninitialized pointer to
 BPF prog
Date: Thu, 31 Jul 2014 13:10:29 -0700 (PDT)
Message-ID: <20140731.131029.385699833260567908.davem@davemloft.net>
References: <1406836139-11943-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, ast@plumgrid.com,
	jiri@resnulli.us
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbaGaUKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:10:34 -0400
In-Reply-To: <1406836139-11943-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 31 Jul 2014 21:48:59 +0200

> Commit 34c5bd66e5ed introduced the possibility that an
> uninitialized pointer on the stack (orig_fp) can call into
> sk_unattached_filter_destroy() when its value is non NULL.
> 
> Before that commit orig_fp was only destroyed in the same
> block where it was assigned a valid BPF prog before. Fix it
> up by initializing it to NULL.
> 
> Fixes: 34c5bd66e5ed ("net: filter: don't release unattached filter through call_rcu()")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
