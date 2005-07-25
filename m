From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/: possible cleanups
Date: Mon, 25 Jul 2005 12:42:57 -0700 (PDT)
Message-ID: <20050725.124257.109907504.davem@davemloft.net>
References: <20050723220530.GO3160@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261472AbVGYTpy@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20050723220530.GO3160@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 24 Jul 2005 00:05:30 +0200

> This patch contains the following possible cleanups:
> - make needlessly global code static
> - #if 0 the following unused global function:
>   - xfrm4_state.c: xfrm4_state_fini
> - remove the following unneeded EXPORT_SYMBOL's:
>   - ip_output.c: ip_finish_output
>   - ip_output.c: sysctl_ip_default_ttl
>   - fib_frontend.c: ip_dev_find
>   - inetpeer.c: inet_peer_idlock
>   - ip_options.c: ip_options_compile
>   - ip_options.c: ip_options_undo
>   - net/core/request_sock.c: sysctl_max_syn_backlog
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Queued up to my net-2.6.14 tree, thanks Adrian.
