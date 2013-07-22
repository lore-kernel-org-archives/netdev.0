From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: pch_gbe depends on x86
Date: Mon, 22 Jul 2013 14:51:55 -0700 (PDT)
Message-ID: <20130722.145155.581647564098552323.davem@davemloft.net>
References: <51d48037.Zcczkb6ouQ0Nv+4v%fengguang.wu@intel.com>
	<1374215169-28866-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ben@decadent.org.uk,
	netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	kbuild-all@01.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374215169-28866-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 19 Jul 2013 08:26:09 +0200

> Since 4bb1667255a86360721291fe59991d033bbc2f2a (build some drivers only
> when compile-testing), PTP_1588_CLOCK_PCH depends on (X86 ||
> COMPILE_TEST). But PCH_GBE selects PTP_1588_CLOCK_PCH without
> depending on x86. Fix this by adding the same dependency here.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Reported-by: <fengguang.wu@intel.com> [intel's build test robot]

Applied, thanks.

Please use lowercase "net: " not uppercase "NET: " in your commit
subject lines.  I fixed it for you this time.

Thank you.
