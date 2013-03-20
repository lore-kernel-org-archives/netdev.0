From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/4] flow_keys: include thoff into
 flow_keys for later usage
Date: Wed, 20 Mar 2013 12:15:20 -0400 (EDT)
Message-ID: <20130320.121520.926290282491389356.davem@davemloft.net>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	<1363711172-9728-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757479Ab3CTQPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:15:22 -0400
In-Reply-To: <1363711172-9728-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 17:39:29 +0100

> In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
> doing the work here anyway, also store thoff for a later usage, e.g. in
> the BPF filter.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  This patch also needs to go into the net tree, since Eric or Jason will
>  post a bug fix on top of this one.

Applied to 'net', thanks Daniel.
