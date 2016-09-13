From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: Re: [PATCH net-next 0/7] cxgb4: add support for offloading TC u32
 filters
Date: Tue, 13 Sep 2016 14:37:59 +0530
Message-ID: <20160913090758.GA30545@chelsio.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:54423 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751625AbcIMJJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 05:09:26 -0400
Content-Disposition: inline
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, September 09/12/16, 2016 at 13:42:33 +0530, Rahul Lakkireddy wrote:
> This series of patches add support to offload TC u32 filters onto
> Chelsio NICs.
> 
> Patch 1 moves current common filter code to separate files
> in order to provide a common api for performing packet classification
> and filtering in Chelsio NICs.
> 
> Patch 2 enables filters for normal NIC configuration and implements
> common api for setting and deleting filters.
> 
> Patch 3 provides a debugfs for dumping filter information.
> 
> Patches 4-7 add support for TC u32 offload via ndo_setup_tc.
> 
> Rahul Lakkireddy (7):
>   cxgb4: move common filter code to separate file
>   cxgb4: add common api support for configuring filters
>   cxgb4: add debugfs support to dump filter debug logs
>   cxgb4: add parser to translate u32 filters to internal spec
>   cxgb4: add support for setting u32 filters
>   cxgb4: add support for deleting u32 filters
>   cxgb4: add support for drop and redirect actions
> 
>  drivers/net/ethernet/chelsio/cxgb4/Makefile        |    2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   30 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |    4 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 1086 ++++++++++++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h  |   50 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  338 ++----
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |  498 +++++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h  |   57 +
>  .../ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h    |  294 ++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   23 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |    5 +-
>  11 files changed, 2104 insertions(+), 283 deletions(-)
>  create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
>  create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
>  create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>  create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
>  create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h
> 
> -- 
> 2.5.3
> 

Thanks for the review Jiri.  Will send a v2 with necessary changes.

Thanks,
Rahul
