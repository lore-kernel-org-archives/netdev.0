From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SELinux: Add support for DCCP
Date: Mon, 13 Nov 2006 16:10:14 -0800 (PST)
Message-ID: <20061113.161014.35469494.davem@davemloft.net>
References: <XMMS.LNX.4.64.0611131612490.9577@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sds@tycho.nsa.gov, arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25513
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933211AbWKNAKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:10:07 -0500
To: jmorris@namei.org
In-Reply-To: <XMMS.LNX.4.64.0611131612490.9577@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 13 Nov 2006 16:15:06 -0500 (EST)

> This patch implements SELinux kernel support for DCCP
> (http://linux-net.osdl.org/index.php/DCCP), which is similar in operation
> to TCP in terms of connected state between peers.
> 
> The SELinux support for DCCP is thus modeled on existing handling of TCP.
> 
> A new DCCP socket class is introduced, to allow protocol differentation.
> The permissions for this class inherit all of the socket permissions, as
> well as the current TCP permissions (node_bind, name_bind etc). IPv4 and
> IPv6 are supported, although labeled networking is not, at this stage.
> 
> Patches for SELinux userspace are at:
> http://people.redhat.com/jmorris/selinux/dccp/user/
> 
> I've performed some basic testing, and it seems to be working as expected.
> Adding policy support is similar to TCP, the only real difference being
> that it's a different protocol.
> 
> Please apply for 2.6.20.
> 
> Also available via git:
> git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.20.git
> 
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>
> Signed-off-by: James Morris <jmorris@namei.org>

Applied to net-2.6.20, thanks.

