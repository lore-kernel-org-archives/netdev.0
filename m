From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Fix truncation length of authentication
 algorithms installed via PF_KEY
Date: Fri, 11 Dec 2009 15:15:39 -0800 (PST)
Message-ID: <20091211.151539.266471885.davem@davemloft.net>
References: <1260375075-16187-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: martin@strongswan.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1260375075-16187-1-git-send-email-martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Willi <martin@strongswan.org>
Date: Wed,  9 Dec 2009 17:11:15 +0100

> Commit 4447bb33f09444920a8f1d89e1540137429351b6 breaks installation of
> authentication algorithms via PF_KEY, as the state specific truncation
> length is not installed with the algorithms default truncation length.
> This patch initializes state properly to the default if installed via
> PF_KEY.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>

Applied.

Herbert, thanks for reviewing, I didn't miss your ACK.  :-)
