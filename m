From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: Fix an overflow bug in vmxnet3 Tx
 descriptor
Date: Sun, 25 Jul 2010 17:06:11 -0700 (PDT)
Message-ID: <20100725.170611.71132252.davem@davemloft.net>
References: <20100725004329.GB6680@bhavesh-lx1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhavesh@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100725004329.GB6680@bhavesh-lx1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Sat, 24 Jul 2010 17:43:29 -0700

> ---

If you put the "---" there are the beginning of your message,
the whole commit message is discarded by GIT.

I said you should put "---" at the end of the commit message,
when you want to add more side commentary that should not appear
in the commit message but is for people in this thread to read.

I fixed this up when adding your patch, but I have no idea why
you did this.  Please don't do it again.

> Fix an overflow bug in vmxnet3 Tx descriptor
> 
> This patch fixes a bug where a 16K buffer on a Tx descriptor was overflowing
> into the 'gen' bit in the descriptor thereby corrupting the descriptor and
> stalling the transmit ring.
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Matthew Delco <delcoM@vmware.com>
> Signed-off-by: Ronghua Zhang <ronghua@vmware.com>

Applied, thanks.
