From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/4] net: flow_dissector: add
 __skb_get_poff to get a start offset to payload
Date: Wed, 20 Mar 2013 13:16:13 -0400 (EDT)
Message-ID: <20130320.131613.2285077146320942322.davem@davemloft.net>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	<1363711172-9728-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763Ab3CTRQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:16:18 -0400
In-Reply-To: <1363711172-9728-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 17:39:30 +0100

> __skb_get_poff() returns the offset to the payload as far as it could
> be dissected. The main user is currently BPF, so that we can dynamically
> truncate packets without needing to push actual payload to the user
> space and instead can analyze headers only.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
