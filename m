From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.37-rc1] net-next: Add multiqueue support to vmxnet3
 driver
Date: Fri, 19 Nov 2010 14:24:39 -0800 (PST)
Message-ID: <20101119.142439.116367673.davem@davemloft.net>
References: <alpine.LRH.2.00.1011191023500.8304@sbhatewara-dev1.eng.vmware.com>
	<20101119.123735.246535099.davem@davemloft.net>
	<alpine.LRH.2.00.1011191252070.22641@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1011191252070.22641@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Fri, 19 Nov 2010 12:55:24 -0800 (PST)

> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> Add multiqueue support to vmxnet3 driver
> 
> This change adds multiqueue and thus receive side scaling support
> to vmxnet3 device driver. Number of rx queues is limited to 1 in cases
> where MSI is not configured or one MSIx vector is not available per rx
> queue
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Reviewed-by: Bhavesh Davda <bhavesh@vmware.com>

Applied, but I still had to fix something up:

> @@ -2726,3 +3277,5 @@ MODULE_AUTHOR("VMware, Inc.");
>  MODULE_DESCRIPTION(VMXNET3_DRIVER_DESC);
>  MODULE_LICENSE("GPL v2");
>  MODULE_VERSION(VMXNET3_DRIVER_VERSION_STRING);
> +
> +

Extraneous blank lines added to the end of a file are considered
errors by GIT, so I removed this hunk.
