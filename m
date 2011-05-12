From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: Use single tx queue when
 CONFIG_PCI_MSI not defined
Date: Thu, 12 May 2011 14:37:30 -0700 (PDT)
Message-ID: <20110512.143730.193713822.davem@davemloft.net>
References: <alpine.LRH.2.00.1105091715150.26660@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.1105100903110.1095@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1105100903110.1095@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Tue, 10 May 2011 09:13:56 -0700 (PDT)

> 
> Resending this patch with few changes.
> 
> 
> Avoid multiple queues when MSI or MSI-X not available
> 
> Limit number of Tx queues to 1 if MSI/MSI-X support is not configured in
> the kernel. This will make number of tx and rx queues equal when MSI/X 
> is not configured thus providing better performance.
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied, thanks.
