From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] em_ipset: use dev_net() accessor
Date: Fri, 18 Oct 2013 16:23:29 -0400 (EDT)
Message-ID: <20131018.162329.1919694379284940208.davem@davemloft.net>
References: <20131016153949.5f2257b4@nehalam.linuxnetplumber.net>
	<525F2D7D.7010708@infradead.org>
	<20131016172934.7913a297@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, lve@guap.ru, thierry.reding@gmail.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	broonie@kernel.org, netdev@vger.kernel.org, jhs@mojatatu.com
To: stephen@networkplumber.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131016172934.7913a297@nehalam.linuxnetplumber.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 16 Oct 2013 17:29:34 -0700

> Randy found that if network namespace not enabled then
> nd_net does not exist and would cause compilation failure.
> 
> This is handled correctly by using the dev_net() macro.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> Acked-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks everyone.
