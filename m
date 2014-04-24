From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91x: improve definition of debug macros
Date: Thu, 24 Apr 2014 13:08:10 -0400 (EDT)
Message-ID: <20140424.130810.1854514715764795522.davem@davemloft.net>
References: <1398222282-8926-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com
To: zlim.lnx@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398222282-8926-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Tue, 22 Apr 2014 20:04:42 -0700

> Redefine some macros that were conditioned upon SMC_DEBUG level.
> 
> By allowing compiler to verify parameters used by these macros
> unconditionally, we can flag compilation failures.
> 
> Compiler will still optimize out the unused code path depending on
> SMC_DEBUG, so this is a net gain.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Applied, thanks.
