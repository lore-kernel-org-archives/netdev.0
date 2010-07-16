From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Thu, 15 Jul 2010 18:32:10 -0700 (PDT)
Message-ID: <20100715.183210.226762655.davem@davemloft.net>
References: <alpine.LRH.2.00.1007131749030.32055@localhost.localdomain>
	<20100714.140718.115934967.davem@davemloft.net>
	<alpine.LRH.2.00.1007151448260.25472@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, ronghua@vmware.com, matthieu@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007151448260.25472@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 15 Jul 2010 18:20:52 -0700 (PDT)

> Is this what you suggest :
> 
> ---
> 
> Hold rtnl_lock to get the right link state.

It ought to work, but make sure that it is legal to take the
RTNL semaphore in all contexts in which this code block
might be called.
