From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] [RESEND] netxen: improve msi support
Date: Tue, 25 Mar 2008 23:19:07 -0400
Message-ID: <47E9C0AB.9010702@garzik.org>
References: <1205809191-20901-1-git-send-email-dhananjay@netxen.com> <1205809191-20901-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbYCZDTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:19:10 -0400
In-Reply-To: <1205809191-20901-2-git-send-email-dhananjay@netxen.com>
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
> Tested-by: Vernon Mauery <mauery@us.ibm.com>
> ---
>  drivers/net/netxen/netxen_nic.h          |    1 +
>  drivers/net/netxen/netxen_nic_hdr.h      |   12 ++++++
>  drivers/net/netxen/netxen_nic_hw.c       |    2 +
>  drivers/net/netxen/netxen_nic_init.c     |    2 +
>  drivers/net/netxen/netxen_nic_main.c     |   56 ++++++++++++-----------------
>  drivers/net/netxen/netxen_nic_phan_reg.h |    3 ++
>  6 files changed, 43 insertions(+), 33 deletions(-)

applied 1-4


