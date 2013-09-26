From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] net: flow_dissector: fix thoff for IPPROTO_AH
Date: Thu, 26 Sep 2013 17:48:43 +0200
Message-ID: <5244575B.8060309@redhat.com>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>  <1380204582-27144-2-git-send-email-nikolay@redhat.com>  <1380209227.3165.176.camel@edumazet-glaptop> <1380210246.3165.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab3IZPxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 11:53:18 -0400
In-Reply-To: <1380210246.3165.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 05:44 PM, Eric Dumazet wrote:
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
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

1 question about my current patchset, can I leave it to get reviewed and if
applied to post a follow-up for net-next that fixes the issue, or would you
prefer a v4 that integrates the fix ?
Anyway for this one,

Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
