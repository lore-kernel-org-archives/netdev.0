From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] netxen: fix link status, link speed
Date: Thu, 07 Aug 2008 02:11:57 -0400
Message-ID: <489A922D.3010906@garzik.org>
References: <> <1217585701-13958-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47922 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198AbYHGGL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:11:59 -0400
In-Reply-To: <1217585701-13958-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> For NX3031, the phy is managed by firmware, so driver should avoid
> setting any phy registers.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_ethtool.c  |   33 +++++++++++++++++++++--------
>  drivers/net/netxen/netxen_nic_hdr.h      |    7 ++++++
>  drivers/net/netxen/netxen_nic_hw.c       |   17 +++++++++++---
>  drivers/net/netxen/netxen_nic_main.c     |   19 +++++++----------
>  drivers/net/netxen/netxen_nic_niu.c      |   12 ++++++++++
>  drivers/net/netxen/netxen_nic_phan_reg.h |    4 +-
>  6 files changed, 66 insertions(+), 26 deletions(-)

applied 1-5


