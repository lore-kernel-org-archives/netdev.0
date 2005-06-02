From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] net/ipv4/: possible cleanups
Date: Thu, 02 Jun 2005 13:13:14 -0700 (PDT)
Message-ID: <20050602.131314.21926883.davem@davemloft.net>
References: <20050530205651.GY10441@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@stusta.de
In-Reply-To: <20050530205651.GY10441@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/ipv4/: possible cleanups
Date: Mon, 30 May 2005 22:56:51 +0200

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
>   - tcp_ipv4.c: sysctl_max_syn_backlog
> 
> Please review which of these changes are correct and which might 
> conflict with pending patches.

Please keep all of the ECN implementation in the
tcp_ecn.h header file, even if the routine is only
called in one C file.

And therefore, please do not remove the tcp_enter_quickack_mode()
extern declaration from tcp.h

Thanks.
