From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support
Date: Wed, 28 Jun 2017 16:37:29 +0200
Message-ID: <20170628143729.l5rv6kixvd3rt45z@localhost.localdomain>
References: <1498636743-3018-1-git-send-email-atul.gupta@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35812 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdF1Ohe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 10:37:34 -0400
Received: by mail-wm0-f44.google.com with SMTP id w126so55449977wme.0
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 07:37:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1498636743-3018-1-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 01:29:03PM +0530, Atul Gupta wrote:
> Add PTP IEEE-1588 support and make it accessible via PHC subsystem.
> The functionality is enabled for T5/T6 adapters. Driver interfaces with
> Firmware to program and adjust the clock offset.
> 
> Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Please put the PTP maintainer onto CC for PTP patches.

>  drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   9 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  25 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  87 +++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c     | 476 +++++++++++++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h     |  74 ++++
>  drivers/net/ethernet/chelsio/cxgb4/sge.c           | 166 ++++++-
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  28 ++
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   2 +
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  50 +++
>  10 files changed, 906 insertions(+), 13 deletions(-)

This should be broken down into a series of at least 2 patches:

1. Transmit hardware SO_TIMESTAMPING

2. PHC support

Thanks,
Richard
