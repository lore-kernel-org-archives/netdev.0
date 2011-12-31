From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ctnetlink: fix timeout calculation
Date: Sat, 31 Dec 2011 16:58:12 +0100
Message-ID: <20111231155812.GB17114@1984>
References: <1325259617-22034-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1325259617-22034-1-git-send-email-xi.wang@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 30, 2011 at 10:40:17AM -0500, Xi Wang wrote:
> The sanity check (timeout < 0) never works; the dividend is unsigned
> and so is the division, which should have been a signed division.
> 
> 	long timeout = (ct->timeout.expires - jiffies) / HZ;
> 	if (timeout < 0)
> 		timeout = 0;
> 
> This patch converts the time values to signed for the division.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied, thanks.
