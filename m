From: David Miller <davem@davemloft.net>
Subject: Re: [v2 8/9] dpaa_eth: add debugfs entries
Date: Fri, 07 Aug 2015 15:37:16 -0700 (PDT)
Message-ID: <20150807.153716.1393797980617992919.davem@davemloft.net>
References: <1438789289-16304-1-git-send-email-madalin.bucur@freescale.com>
	<1438789289-16304-9-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	igal.liberman@freescale.com, ppc@mindchasers.com, joe@perches.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438789289-16304-9-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Wed, 5 Aug 2015 18:41:28 +0300

> Export per CPU counters through debugfs.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>

This is absolutely inappropriate.

You can export these just fine via ethtool statistics.  There is zero reason
to add ugly debugfs crap for something like this.
