From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.1] Net device error logging
Date: Mon, 19 Jan 2004 18:46:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119184630.5d066735.akpm@osdl.org>
References: <400C3D3E.BFCC25CE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        jkenisto@us.ibm.com, scott.feldman@intel.com, kessler@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <400C3D3E.BFCC25CE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jim Keniston <jkenisto@us.ibm.com> wrote:
>
> The enclosed patch implements the netdev_* error-logging macros for
>  network drivers.

Looks OK to me.

But it does make one wonder whether we'll soon see standalone patches for
scsi_printk(), pci_bridge_printk(), random_other_subsystem_printk(), ...?

Or is it intended that the backend logging code will be implemented mainly
in terms of the `struct device'?  So netdev_printk() will be a bit of
netdev-specific boilerplate which then calls into a more generic
device_printk()?
