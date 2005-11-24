From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 16:50:37 -0800 (PST)
Message-ID: <20051123.165037.130468768.davem@davemloft.net>
References: <4384E7F2.2030508@pobox.com>
	<20051123223007.GA5921@wotan.suse.de>
	<20051124001700.GC14246@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, jgarzik@pobox.com, andrew.grover@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030549AbVKXAuu@vger.kernel.org>
To: bcrl@kvack.org
In-Reply-To: <20051124001700.GC14246@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Wed, 23 Nov 2005 19:17:01 -0500

> Similarly, we should make sure that network drivers prefetch the
> header at the earliest possible time, too.

Several do already, thankfully :)  At last check skge, tg3, chelsio,
and ixgb do the necessary prefetching on receive.
