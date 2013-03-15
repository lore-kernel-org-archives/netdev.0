From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers:net: Remove dma_alloc_coherent OOM
 messages
Date: Fri, 15 Mar 2013 08:57:39 -0400 (EDT)
Message-ID: <20130315.085739.1428933964050018561.davem@davemloft.net>
References: <1363302441.2146.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	b43-dev@lists.infradead.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363302441.2146.30.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 14 Mar 2013 16:07:21 -0700

> I believe these error messages are already logged
> on allocation failure by warn_alloc_failed and so
> get a dump_stack on OOM.
> 
> Remove the unnecessary additional error logging.
> 
> Around these deletions:
> 
> o Alignment neatening.
> o Remove unnecessary casts of dma_alloc_coherent.
> o Hoist assigns from ifs.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
