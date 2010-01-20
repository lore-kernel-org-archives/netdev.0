From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 20 Jan 2010 14:45:00 -0800 (PST)
Message-ID: <20100120.144500.40591155.davem@davemloft.net>
References: <20100120100316.2b5b1b05@nehalam>
	<1264018312.9030.76.camel@nseg_linux_HP1.broadcom.com>
	<20100120123033.0746b11e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jarkao2@gmail.com, mbreuer@majjas.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pcnet32@verizon.net, romieu@fr.zoreil.com, mcarlson@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754803Ab0ATWox@vger.kernel.org>
In-Reply-To: <20100120123033.0746b11e@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 20 Jan 2010 12:30:33 -0800

> It looks like the size passed to sync_single has to match size of original
> mapping.

I think that's rediculious, and unreasonable.

All implementations of these APIs where the sync matters have the
ability to handle partial syncs correctly.
