From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 2/4] net: vrf: call
 netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 21:41:17 -0600
Message-ID: <c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com>
 <1465442964-5786-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34462 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbcFIDlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 23:41:20 -0400
Received: by mail-pf0-f181.google.com with SMTP id 62so8921997pfd.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 20:41:20 -0700 (PDT)
In-Reply-To: <1465442964-5786-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/16 9:29 PM, Eric Dumazet wrote:
> In case a qdisc is used on a vrf device, we need to use different
> lockdep classes to avoid false positives.
>
> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

same result with this patch set.
