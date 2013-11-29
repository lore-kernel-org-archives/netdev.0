From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] update consumers of MSG_MORE to recognize
 MSG_SENDPAGE_NOTLAST
Date: Fri, 29 Nov 2013 16:33:39 -0500 (EST)
Message-ID: <20131129.163339.2047522433275114284.davem@davemloft.net>
References: <20131125042633.GA4156@order.stressinduktion.org>
	<1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	viro@zeniv.linux.org.uk, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	therbert@google.com, stable@vger.kernel.org
To: shawn@churchofgit.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1385361388-2175-1-git-send-email-shawn@churchofgit.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shawn Landden <shawn@churchofgit.com>
Date: Sun, 24 Nov 2013 22:36:28 -0800

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
> 
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: <stable@vger.kernel.org> # 3.4.x + 3.2.x
> Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
> Original-patch: Richard Weinberger <richard@nod.at>
> Signed-off-by: Shawn Landden <shawn@churchofgit.com>

Applied and queued up for -stable, thanks everyone.
