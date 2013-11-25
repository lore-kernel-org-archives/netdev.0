From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLAST
Date: Mon, 25 Nov 2013 05:26:33 +0100
Message-ID: <20131125042633.GA4156@order.stressinduktion.org>
References: <1385342706.10637.125.camel@edumazet-glaptop2.roam.corp.google.com> <1385345339-2184-1-git-send-email-shawn@churchofgit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Shawn Landden <shawn@churchofgit.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385345339-2184-1-git-send-email-shawn@churchofgit.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 24, 2013 at 06:08:59PM -0800, Shawn Landden wrote:
> Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag MSG_SENDPAGE_NOTLAST, similar to
> MSG_MORE.
> 
> algif_hash and algif_skcipher used MSG_MORE from tcp_sendpages()
> and need to see the new flag as identical to MSG_MORE.
> 
> This fixes sendfile() on AF_ALG.

Don't we need a similar fix for udp_sendpage?

Greetings,

  Hannes
