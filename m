From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next v1 0/7] Fix, cleanup, optimize gfar_private and
 the Rx path
Date: Thu, 14 Feb 2013 11:49:45 -0500
Message-ID: <511D15A9.9090001@windriver.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53628 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755410Ab3BNQtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:49:14 -0500
In-Reply-To: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-02-14 10:00 AM, Claudiu Manoil wrote:
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
>   "David S. Miller" <davem@davemloft.net>
> 
> 
> Hi Dave,
> These patches went already through a review round with Paul.
> Changes since the initial version of the patches:
> * split the 1st patch into two patches (01 & 02, as suggested by Paul)
> * added the suggested trivial cleanup patch:
>   gianfar: gfar_process_frame returns void
> * provided "long logs" with detailed comments and explanations

The commit headers do look a lot better, thanks.  Passes basic boot
test on today's net-next with sbc8548 and NFS root.

Paul.
--

> 
> Thank you.
> 
> Regards,
> Claudiu
> 
> 
> Claudiu Manoil (7):
>   gianfar: Remove unused device_node ref in gfar_private
>   gianfar: Add device ref (dev) in gfar_private
>   gianfar: Cleanup and optimize struct gfar_private
>   gianfar: GRO_DROP is unlikely
>   gianfar: gfar_process_frame returns void
>   gianfar: Remove wrong buffer size conditioning to VLAN h/w offload
>   gianfar: Fix and cleanup Rx FCB indication
> 
>  drivers/net/ethernet/freescale/gianfar.c |   85 ++++++++++++---------------
>  drivers/net/ethernet/freescale/gianfar.h |   96 +++++++++++++++--------------
>  2 files changed, 88 insertions(+), 93 deletions(-)
> 
