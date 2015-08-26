From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 3/5] net_sched: convert tcindex to call tcf_exts_destroy
 from rcu callback
Date: Wed, 26 Aug 2015 10:09:46 +0200
Message-ID: <55DD744A.3010304@iogearbox.net>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com> <1440558395-7765-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53664 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbHZIJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:09:50 -0400
In-Reply-To: <1440558395-7765-4-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 05:06 AM, Alexei Starovoitov wrote:
> Adjust destroy path of cls_tcindex to call tcf_exts_destroy() after
> rcu grace period.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
