From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net/xfrm/xfrm_replay: avoid division by zero
Date: Fri, 18 Jan 2013 09:57:23 +0100
Message-ID: <20130118085723.GG24987@secunet.com>
References: <1358449108-67839-1-git-send-email-nickolai@csail.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nickolai Zeldovich <nickolai@csail.mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358449108-67839-1-git-send-email-nickolai@csail.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 17, 2013 at 01:58:28PM -0500, Nickolai Zeldovich wrote:
> All of the xfrm_replay->advance functions in xfrm_replay.c check if
> x->replay_esn->replay_window is zero (and return if so).  However,
> one of them, xfrm_replay_advance_bmp(), divides by that value (in the
> '%' operator) before doing the check, which can potentially trigger
> a divide-by-zero exception.  Some compilers will also assume that the
> earlier division means the value cannot be zero later, and thus will
> eliminate the subsequent zero check as dead code.
> 
> This patch moves the division to after the check.
> 
> Signed-off-by: Nickolai Zeldovich <nickolai@csail.mit.edu>

Applied, thanks!
