From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vxge: add missing flush of reset_task
Date: Sun, 19 Dec 2010 21:54:23 -0800 (PST)
Message-ID: <20101219.215423.115923060.davem@davemloft.net>
References: <4D08CAB1.6040402@kernel.org>
	<20101215142859.GA13516@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jon.mason@exar.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101215142859.GA13516@exar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@exar.com>
Date: Wed, 15 Dec 2010 08:29:00 -0600

> On Wed, Dec 15, 2010 at 06:03:29AM -0800, Tejun Heo wrote:
>> Commit 6e07ebd84 (drivers/net: remove unnecessary
>> flush_scheduled_work() calls) incorrectly removed the flush call
>> without replacing it with the appropriate work specific operation.
>> Fix it by flushing vdev->reset_task explicitly.
>> 
>> Pointed out by Jon Mason.
>> 
>> Signed-off-by: Tejun Heo <tj@kernel.org>
>> Cc: Jon Mason <jon.mason@exar.com>
> Acked-by: Jon Mason <jon.mason@exar.com>

I'll apply this, thanks.
