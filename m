From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/4] net: flow_dissector: add __skb_get_poff
 to get a start offset to payload
Date: Tue, 19 Mar 2013 09:42:35 -0700
Message-ID: <1363711355.2558.18.camel@edumazet-glaptop>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	 <1363711172-9728-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:58575 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757134Ab3CSQmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 12:42:37 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so579676pbc.2
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 09:42:37 -0700 (PDT)
In-Reply-To: <1363711172-9728-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 17:39 +0100, Daniel Borkmann wrote:
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
