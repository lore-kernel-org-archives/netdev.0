From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] appletalk: remove an unused function
Date: Thu, 28 Oct 2004 16:26:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028162643.2ee7e30e.davem@davemloft.net>
References: <20041028221046.GI3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041028221046.GI3207@stusta.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 00:10:46 +0200
Adrian Bunk <bunk@stusta.de> wrote:

> - -static inline void atalk_insert_socket(struct sock *sk)
> - -{
> - -	write_lock_bh(&atalk_sockets_lock);
> - -	__atalk_insert_socket(sk);
> - -	write_unlock_bh(&atalk_sockets_lock);
> - -}
> - -

This is a patch of a patch, I doubt it will apply cleanly ;-)
