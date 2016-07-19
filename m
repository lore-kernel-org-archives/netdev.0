From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: BUG: Wrong dma queue handling in ixp4 driver
Date: Tue, 19 Jul 2016 13:31:49 +0200
Message-ID: <trinity-28228d79-2b64-4d9c-89c2-6ce288a8ed49-1468927909503@3capp-gmx-bs21>
References: <trinity-275fae16-c9c8-4503-85fe-5585fb014c7a-1468926357992@3capp-gmx-bs21>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khalasa@piap.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <trinity-275fae16-c9c8-4503-85fe-5585fb014c7a-1468926357992@3capp-gmx-bs21>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Hi,
> 
> maybe I miss something, but the ixp4 ethernet driver seems to handle dma pools 
> in a wrong way: In init_queues() it creates a dma pool for descriptors and then
>  only allocates a single descriptor from this pool. The author seems to assume the whole
> table has been allocated already, since after that the complete pool size is zeroed:
> 

Sorry, I indeed missed something. The allocation is correct. A pool is not required, though,
since only one chunk is allocated.

Lino
