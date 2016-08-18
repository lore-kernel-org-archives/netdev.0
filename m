From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCHv3] net: ethernet: macb: Add support for rx_clk
Date: Thu, 18 Aug 2016 13:58:57 -0500
Message-ID: <20160818185857.GA9311@rob-hp-laptop>
References: <1471322690-35923-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        soren.brinkmann@xilinx.com, shubhrajyoti.datta@gmail.com,
        michal.simek@xilinx.com
To: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35692 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753803AbcHSAwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:52:36 -0400
Content-Disposition: inline
In-Reply-To: <1471322690-35923-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 10:14:50AM +0530, Shubhrajyoti Datta wrote:
> Some of the platforms like zynqmp ultrascale+ has a
> separate clock gate for the rx clock. Add an optional
> rx_clk so that the clock can be enabled.
> 
> Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
> ---
> v2:
> fix warnng
> v3
> Add that rx applies to zcu mpsoc
> 
>  Documentation/devicetree/bindings/net/macb.txt |  1 +

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/ethernet/cadence/macb.c            | 31 +++++++++++++++++++++-----
>  drivers/net/ethernet/cadence/macb.h            |  4 +++-
>  3 files changed, 30 insertions(+), 6 deletions(-)
