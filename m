From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] nfs: fix dead code of ipv6_addr_scope
Date: Mon, 23 Dec 2013 04:18:45 +0100
Message-ID: <20131223031845.GM14073@order.stressinduktion.org>
References: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, werner@almesberger.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 23, 2013 at 12:01:16AM +0100, Alexander Aring wrote:
> This patch corrects the check on a linklocal address.
> 
> Currently this can't be work, because ipv6_addr_scope returns a int with
> a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
> is 0x02. So the condition is always false.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
