From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [ethtool 1/1] ethtool: Add DMA Coalescing support
Date: Fri, 25 Aug 2017 15:57:16 -0700
Message-ID: <20170825155716.630e6f72@xeon-e3>
References: <20170825223910.54989-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Paul Greenwalt <paul.greenwalt@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:32953 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964787AbdHYW5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:57:24 -0400
Received: by mail-pg0-f54.google.com with SMTP id t3so6093478pgt.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 15:57:24 -0700 (PDT)
In-Reply-To: <20170825223910.54989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 15:39:10 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 06fc04c..4bb91eb 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -400,6 +400,7 @@ struct ethtool_modinfo {
>   *	a TX interrupt, when the packet rate is above @pkt_rate_high.
>   * @rate_sample_interval: How often to do adaptive coalescing packet rate
>   *	sampling, measured in seconds.  Must not be zero.
> + * @dmac: How many usecs to store packets before moving to host memory.
>   *
>   * Each pair of (usecs, max_frames) fields specifies that interrupts
>   * should be coalesced until
> @@ -450,6 +451,7 @@ struct ethtool_coalesce {
>  	__u32	tx_coalesce_usecs_high;
>  	__u32	tx_max_coalesced_frames_high;
>  	__u32	rate_sample_interval;
> +	__u32	dmac;
>  };
>  

Because of backwards ABI compatibility, it is not safe to extend
an existing structure.
