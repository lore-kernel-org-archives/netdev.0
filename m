From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Handle changes to the VMCI context ID.
Date: Tue, 02 Apr 2013 14:39:46 -0400 (EDT)
Message-ID: <20130402.143946.956982729576009415.davem@davemloft.net>
References: <1364841712-22810-1-git-send-email-grantr@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: grantr@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364841712-22810-1-git-send-email-grantr@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Reilly Grant <grantr@vmware.com>
Date: Mon,  1 Apr 2013 11:41:52 -0700

> The VMCI context ID of a virtual machine may change at any time. There
> is a VMCI event which signals this but datagrams may be processed before
> this is handled. It is therefore necessary to be flexible about the
> destination context ID of any datagrams received. (It can be assumed to
> be correct because it is provided by the hypervisor.) The context ID on
> existing sockets should be updated to reflect how the hypervisor is
> currently referring to the system.
> 
> Signed-off-by: Reilly Grant <grantr@vmware.com>
> Acked-by: Andy King <acking@vmware.com>

Applied, thanks.
