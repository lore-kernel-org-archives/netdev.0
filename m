From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxge: Remove unnecessary ; in do {} while (0)
 macro
Date: Tue, 03 Apr 2012 17:58:37 -0400 (EDT)
Message-ID: <20120403.175837.1897033408784057713.davem@davemloft.net>
References: <1333489992.2695.17.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333489992.2695.17.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 03 Apr 2012 14:53:12 -0700

> This macro doesn't need a terminating ; so just remove it.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.

Longer term I'd much rather see this turned into an inline
function with proper type checking etc.
