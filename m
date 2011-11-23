From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [PATCH] netprio_cgroup: Fix build break
Date: Wed, 23 Nov 2011 17:11:47 +0400
Message-ID: <20111123131147.GA11508@tugrik.mns.mnsspb.ru>
References: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:58892 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122Ab1KWNOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 08:14:02 -0500
Content-Disposition: inline
In-Reply-To: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 07:32:33AM -0500, Neil Horman wrote:
> I broke the build with the addition of netprio_cgroups if CONFIG_CGROUPS=n.
> This patch corrects it by moving the offending struct into an ifdef
> CONFIG_CGROUPS block.  Also clean up a few needless defines and inline functions
> that don't get called if CONFIG_CGROUPS isn't defined while Im at it.

Thanks Neil, now it compiles ok.
