From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: prevent div-by-zero panic when ring
 resizing uninitialized dev
Date: Thu, 07 Mar 2013 16:11:28 -0500 (EST)
Message-ID: <20130307.161128.530029379718111617.davem@davemloft.net>
References: <1362591984-16587-1-git-send-email-bhavesh@vmware.com>
	<1362607493-5634-1-git-send-email-bhavesh@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, sbhatewara@vmware.com
To: bhavesh@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362607493-5634-1-git-send-email-bhavesh@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Wed,  6 Mar 2013 14:04:53 -0800

> Linux is free to call ethtool ops as soon as a netdev exists when probe
> finishes. However, we only allocate vmxnet3 tx/rx queues and initialize the
> rx_buf_per_pkt field in struct vmxnet3_adapter when the interface is
> opened (UP).
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

As discussed yesterday, I'm applying this to 'net', thanks.
