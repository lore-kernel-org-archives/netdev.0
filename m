From: David Miller <davem@davemloft.net>
Subject: Re: e1000 driver 2.6.18 - how to waste processor cycles
Date: Wed, 08 Nov 2006 18:43:53 -0800 (PST)
Message-ID: <20061108.184353.106435332.davem@davemloft.net>
References: <45524E3A.7080301@soleranetworks.com>
	<4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmerkey@soleranetworks.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754301AbWKICnt@vger.kernel.org>
To: jesse.brandeburg@gmail.com
In-Reply-To: <4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Date: Wed, 8 Nov 2006 17:01:44 -0800

> If you can show that it is faster to use pci_dma_sync_single_for_cpu
> and friends I'd be glad to take a patch.

The problem is if you don't recycle the buffer and really unmap,
you'll flush twice.  That can potentially be expensive.
