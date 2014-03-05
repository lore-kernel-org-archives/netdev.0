From: Eyal Perry <eyalpe@dev.mellanox.co.il>
Subject: Re: mlx4_core: DMA-API: device driver tries to sync DMA memory it
 has not allocated
Date: Wed, 5 Mar 2014 18:25:52 +0200
Message-ID: <20140305162534.GA19488@mtl-eit-vdi-146.mtl.labs.mlnx>
References: <20131210144416.31b7002c@thinkpad>
 <20140227170107.GB24226@mtl-eit-vdi-22.mtl.labs.mlnx>
 <20140228222457.3db91448@vbox-ubuntu>
 <20140302084046.GD809@mtl-eit-vdi-22.mtl.labs.mlnx>
 <20140303185832.67862975@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140303185832.67862975@thinkpad>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/14 18:58 +0100, Gerald Schaefer wrote:
> I checked again with 3.10 and 3.11, and couldn't reproduce the warning
> there. However, there is another warning on those kernel versions:
> 
> mlx4_core 0000:00:00.0: DMA-API: device driver failed to check map error[device address=0x00000001046af186] [size=258 bytes] [mapped as single]
> 
> That one was fixed with commit 237a3a3b "net/mlx4_en: Fix handling of dma_map failure".
> When I apply commit 237a3a3b on top of 3.11, I can also reproduce the
> new "sync DMA" warning there.
> 
> So, either the new "sync DMA" warning was introduced with commit 237a3a3b,
> or it was just occluded by the previous "map error" warning.
Hi Gerald,
Thanks for the update and for your efforts on investigating this issue,
we are currently working on reproducing this issue on our lab in order
to understand thoroughly the root cause.

Eyal
