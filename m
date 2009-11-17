From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32-rc3] net: Getting rid of the x86 dependency to
 built vmxnet3
Date: Tue, 17 Nov 2009 04:09:34 -0800 (PST)
Message-ID: <20091117.040934.190018835.davem@davemloft.net>
References: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.0911161053050.23246@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755999AbZKQMJT@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0911161053050.23246@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Mon, 16 Nov 2009 15:41:33 -0800 (PST)

> 
> Getting rid of the x86 dependency to built vmxnet3
> 
> From: Shreyas Bhatewara <sbhatewara@vmware.com>
> 
> This patch removes config dependency on x86 to build vmxnet3 driver. Thus 
> the driver can be built on big endian architectures now. Although vmxnet3 
> is not supported on VMs other than x86 architecture, all this code goes in 
> to ensure correctness. If the code is not dependent on x86, it should not 
> assume little endian architecture in any of its operations.
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

Patch applied, thanks for following up on this.
