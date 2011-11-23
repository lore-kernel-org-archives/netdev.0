From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netprio_cgroup: Fix build break
Date: Wed, 23 Nov 2011 15:53:05 -0500 (EST)
Message-ID: <20111123.155305.1621375962249427854.davem@davemloft.net>
References: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kirr@mns.spb.ru,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 23 Nov 2011 07:32:33 -0500

> I broke the build with the addition of netprio_cgroups if CONFIG_CGROUPS=n.
> This patch corrects it by moving the offending struct into an ifdef
> CONFIG_CGROUPS block.  Also clean up a few needless defines and inline functions
> that don't get called if CONFIG_CGROUPS isn't defined while Im at it.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
