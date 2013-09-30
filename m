From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: flow_dissector: fix thoff for IPPROTO_AH
Date: Mon, 30 Sep 2013 15:34:04 -0400 (EDT)
Message-ID: <20130930.153404.269524833698262050.davem@davemloft.net>
References: <1380204582-27144-2-git-send-email-nikolay@redhat.com>
	<1380209227.3165.176.camel@edumazet-glaptop>
	<1380210246.3165.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, dborkman@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com, vfalico@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783Ab3I3TeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:34:09 -0400
In-Reply-To: <1380210246.3165.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Sep 2013 08:44:06 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 8ed781668dd49 ("flow_keys: include thoff into flow_keys for
> later usage"), we missed that existing code was using nhoff as a
> temporary variable that could not always contain transport header
> offset.
> 
> This is not a problem for TCP/UDP because port offset (@poff)
> is 0 for these protocols.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
