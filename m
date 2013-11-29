From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLAST
Date: Fri, 29 Nov 2013 06:47:04 +0100
Message-ID: <20131129054704.GI24171@order.stressinduktion.org>
References: <20131125042633.GA4156@order.stressinduktion.org> <1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	richard.weinberger@gmail.com
To: Shawn Landden <shawn@churchofgit.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 24, 2013 at 10:36:28PM -0800, Shawn Landden wrote:
> Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag MSG_SENDPAGE_NOTLAST, similar to
> MSG_MORE.
> 
> algif_hash, algif_skcipher, and udp used MSG_MORE from tcp_sendpages()
> and need to see the new flag as identical to MSG_MORE.
> 
> This fixes sendfile() on AF_ALG.
> 
> v3: also fix udp

The UDP bits look fine to me.

Greetings,

  Hannes

