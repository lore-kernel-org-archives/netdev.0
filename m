From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: CLUSTERIP: clusterip_seq_stop() fix
Date: Thu, 01 Apr 2010 12:54:41 +0200
Message-ID: <4BB47B71.2080009@trash.net>
References: <1269539686-3885-1-git-send-email-kaber@trash.net>	 <1269539686-3885-2-git-send-email-kaber@trash.net>	 <1269539686-3885-3-git-send-email-kaber@trash.net> <1269546442.2894.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269546442.2894.5.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> If clusterip_seq_start() memory allocation fails, we crash later in
> clusterip_seq_start(), trying to kfree(ERR_PTR(-ENOMEM))

Applied, thanks Eric.
