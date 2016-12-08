From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 0/3] i40e: Support for XDP
Date: Thu, 8 Dec 2016 09:52:41 -0800
Message-ID: <58499DE9.3060908@gmail.com>
References: <20161208170022.11555-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        magnus.karlsson@intel.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34724 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbcLHRw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:52:56 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so22642539pfb.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:52:56 -0800 (PST)
In-Reply-To: <20161208170022.11555-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-08 09:00 AM, Björn Töpel wrote:
> From: Björn Töpel <bjorn.topel@intel.com>
> 
> This series adds XDP support for i40e-based NICs.
> 
> The first patch adds XDP_RX support, the second XDP_TX support and the
> last patch makes it possible to change an XDP program without
> rebuilding the rings.
> 
> 
> Björn
> 
> 
> Björn Töpel (3):
>   i40e: Initial support for XDP
>   i40e: Add XDP_TX support
>   i40e: Don't reset/rebuild rings on XDP program swap
> 
>  drivers/net/ethernet/intel/i40e/i40e.h         |  18 +
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   3 +
>  drivers/net/ethernet/intel/i40e/i40e_main.c    | 358 +++++++++++++++++---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 445 +++++++++++++++++++++----
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   7 +
>  5 files changed, 715 insertions(+), 116 deletions(-)
> 

Hi Jeff,

These are for the Intel driver net-next tree per our offlist email.

Thanks!
John
