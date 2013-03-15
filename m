From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Support VM sockets connected to the hypervisor.
Date: Fri, 15 Mar 2013 08:25:30 -0400 (EDT)
Message-ID: <20130315.082530.1920500635070584515.davem@davemloft.net>
References: <1363117219-21911-1-git-send-email-grantr@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: grantr@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363117219-21911-1-git-send-email-grantr@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Reilly Grant <grantr@vmware.com>
Date: Tue, 12 Mar 2013 12:40:19 -0700

> The resource ID used for VM socket control packets (0) is already
> used for the VMCI_GET_CONTEXT_ID hypercall so a new ID (15) must be
> used when the guest sends these datagrams to the hypervisor.
> 
> The hypervisor context ID must also be removed from the internal
> blacklist.
> 
> Signed-off-by: Reilly Grant <grantr@vmware.com>
> Acked-by: Andy King <acking@vmware.com>

Applied, thanks.
