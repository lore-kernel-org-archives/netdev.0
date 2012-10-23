From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Tue, 23 Oct 2012 02:36:47 -0400 (EDT)
Message-ID: <20121023.023647.2164665243829038911.davem@davemloft.net>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: cardoe@cardoe.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Goldstein <cardoe@cardoe.com>
Date: Mon, 22 Oct 2012 00:53:57 -0500

> Sets the sysfs device_type to 'vlan' for udev. This makes it easier for
> applications that query network information via udev to identify vlans
> instead of using strrchr().
> 
> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>

You're extremely misguided.  This change, in fact, makes it ten times
harder for such applications to query such devices.

Because now the application has to decide whether it wants to support
EVERY EXISTING SYSTEM OUT THERE or not.  Hundreds of millions of Linux
systems do not provide this attribute.

Applications have to handle the case of not having the 'vlan' device
type available attribute essentially forever.

So providing it in new kernels provides zero value whatsoever.

I'm not applying this patch, sorry.
