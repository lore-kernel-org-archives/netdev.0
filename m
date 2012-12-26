From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Don't leak 'exp' in
 ctnetlink_create_expect()
Date: Wed, 26 Dec 2012 23:09:02 +0100
Message-ID: <20121226220902.GA30981@1984>
References: <alpine.LNX.2.00.1212262246390.23814@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jay Schulist <jschlst@samba.org>,
	Harald Welte <laforge@gnumonks.org>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212262246390.23814@swampdragon.chaosbits.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 26, 2012 at 10:49:40PM +0100, Jesper Juhl wrote:
> 'if ((!help) && (!cda[CTA_EXPECT_TIMEOUT]))' then we should remember
> to free 'exp' that was allocated by 'nf_ct_expect_alloc()' by jumping
> to the 'err_out' label rather than the 'out' label in
> ctnetlink_create_expect().
> This patch should get rid of the leak.

Applied, thanks Jesper.
