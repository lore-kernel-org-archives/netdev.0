From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: h323: Use mod_timer instead of
 set_expect_timeout
Date: Sat, 23 Jul 2016 12:28:09 +0200
Message-ID: <20160723102809.GA3204@salvia>
References: <1469163555-13170-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469163555-13170-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 22, 2016 at 12:59:15PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> It could simplify the codes without any side effect.
> The set_expect_timeout is used to modify the timer expired time.
> It tries to delete timer, and add it again.
> So we could use mod_timer directly.

Applied, thanks.
