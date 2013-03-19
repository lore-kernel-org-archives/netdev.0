From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/4] net: flow_dissector: add __skb_get_poff
 to get a start offset to payload
Date: Tue, 19 Mar 2013 08:03:59 -0700
Message-ID: <1363705439.2558.4.camel@edumazet-glaptop>
References: <cover.1363702456.git.dborkman@redhat.com>
	 <fd6036248f9337e3679cb441f262ce5d5b228c9b.1363702456.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:60862 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831Ab3CSPEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 11:04:02 -0400
Received: by mail-da0-f50.google.com with SMTP id t1so359213dae.23
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 08:04:02 -0700 (PDT)
In-Reply-To: <fd6036248f9337e3679cb441f262ce5d5b228c9b.1363702456.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 15:34 +0100, Daniel Borkmann wrote:
> __skb_get_poff() returns the offset to the payload as far as it could
> be dissected. The main user is currently BPF, so that we can dynamically
> truncate packets without needing to push actual payload to the user
> space and instead can analyze headers only.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/linux/skbuff.h    |  2 ++
>  net/core/flow_dissector.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 59 insertions(+)

Acked-by: Eric Dumazet <edumazet@google.com>
