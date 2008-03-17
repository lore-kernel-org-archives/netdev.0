From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] netxen: improve msi support
Date: Mon, 17 Mar 2008 08:08:24 -0400
Message-ID: <47DE5F38.5040106@garzik.org>
References: <Pine.LNX.4.64.0803120059270.7717@unm84.unminc.com> <Pine.LNX.4.64.0803120118400.7717@unm84.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbYCQMIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:08:25 -0400
In-Reply-To: <Pine.LNX.4.64.0803120118400.7717@unm84.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> Recent netxen firmware has new scheme of generating MSI interrupts, it
> raises interrupt and blocks itself, waiting for driver to unmask. This
> reduces chance of spurious interrupts.
> 
> The driver will be able to deal with older firmware as well.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h          |    1 +
>  drivers/net/netxen/netxen_nic_hdr.h      |   12 ++++++
>  drivers/net/netxen/netxen_nic_hw.c       |    2 +
>  drivers/net/netxen/netxen_nic_init.c     |    2 +
>  drivers/net/netxen/netxen_nic_main.c     |   56 ++++++++++++-----------------
>  drivers/net/netxen/netxen_nic_phan_reg.h |    3 ++
>  6 files changed, 43 insertions(+), 33 deletions(-)

ACK patches 1-4, but does not apply to #upstream-fixes (nor davem's net-2.6)


