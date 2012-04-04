From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/7] bna: Update driver version to 3.0.23.0
Date: Wed, 4 Apr 2012 10:15:35 -0700
Message-ID: <20120404101535.0b739155@s6510.linuxnetplumber.net>
References: <1332790673-9562-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@brocade.com>
To: Jing Huang <huangj@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60515 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756327Ab2DDRPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 13:15:39 -0400
In-Reply-To: <1332790673-9562-1-git-send-email-huangj@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Mar 2012 12:37:53 -0700
Jing Huang <huangj@brocade.com> wrote:

> This patch set contains fixes in adapter initialization and tx/rx cleanup path.
> It also include code cleanups by removing and renaming some functions.
> 
> The driver version has been updated to 3.0.23.0 to reflect the changes.
> 
> Jing Huang (7):
>   bna: Serialize smem access during adapter initialization
>   bna: Flash controller ioc pll init fixes
>   bna: ioc cleanups
>   bfa: tx rx cleanup fix
>   bna: Remove tx tasklet
>   bfa: Function name changes and cleanups
>   bfa: Update driver version to 3.0.23.0
> 
>  drivers/net/ethernet/brocade/bna/bfa_ioc.c      |   61 +++--
>  drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c   |  142 +++++++----
>  drivers/net/ethernet/brocade/bna/bfi_reg.h      |    6 +
>  drivers/net/ethernet/brocade/bna/bnad.c         |  316 +++++++++++------------
>  drivers/net/ethernet/brocade/bna/bnad.h         |   11 +-
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    6 +-
>  6 files changed, 300 insertions(+), 242 deletions(-)
> 

When are you going to integrate multi-queue support which is already
available in your out of tree driver?
