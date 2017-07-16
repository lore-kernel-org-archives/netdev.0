From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fragmented SKB corrections
Date: Sat, 15 Jul 2017 21:29:54 -0700 (PDT)
Message-ID: <20170715.212954.286118168709267918.davem@davemloft.net>
References: <20170714231210.12967-1-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org
To: opendmb@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714231210.12967-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <opendmb@gmail.com>
Date: Fri, 14 Jul 2017 16:12:08 -0700

> Two issues were observed in a review of the bcmgenet driver support for
> fragmented SKBs which are addressed by this patch set.
> 
> The first addresses a problem that could occur if the driver is not able
> to DMA map a fragment of the SKB.  This would be a highly unusual event
> but it would leave the hardware descriptors in an invalid state which
> should be prevented.
> 
> The second is a hazard that could occur if the driver is able to reclaim
> the first control block of a fragmented SKB before all of its fragments
> have completed processing by the hardware.  In this case the SKB could
> be freed leading to reuse of memory that is still in use by hardware.

Series applied, thanks.
