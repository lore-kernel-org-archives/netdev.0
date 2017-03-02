From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH net v4 0/2] net: ethernet: bgmac: bug fixes
Date: Thu, 2 Mar 2017 17:57:05 -0500
Message-ID: <20170302225704.GA5178@broadcom.com>
References: <1488307311-11933-1-git-send-email-jon.mason@broadcom.com>
 <20170302.125015.275943458708603387.davem@davemloft.net>
 <20170302.125605.1084925031741881031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34821 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdCCAsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 19:48:00 -0500
Received: by mail-qk0-f170.google.com with SMTP id m67so37679352qkf.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 16:47:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170302.125605.1084925031741881031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 02, 2017 at 12:56:05PM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 02 Mar 2017 12:50:15 -0800 (PST)
> 
> > From: Jon Mason <jon.mason@broadcom.com>
> > Date: Tue, 28 Feb 2017 13:41:49 -0500
> > 
> >> Changes in v4:
> >> * Added the udelays from the previous code (per David Miller)
> >> 
> >> Changes in v3:
> >> * Reworked the init sequence patch to only remove the device reset if
> >>   the device is actually in reset.  Given that this code doesn't bear
> >>   much resemblance to the original code, I'm changing the author of the
> >>   patch.  This was tested on NS2 SVK.
> >> 
> >> Changes in v2:
> >> * Reworked the first match to make it more obvious what portions of the
> >>   register were being preserved (Per Rafal Mileki)
> >> * Style change to reorder the function variables in patch 2 (per Sergei
> >>   Shtylyov)
> >> 
> >> Bug fixes for bgmac driver
> > 
> > Series applied.
> 
> Actually, this doesn't even compile.  Reverted...
> 
> [davem@kkuri net]$ make -s -j4
> drivers/net/ethernet/broadcom/bgmac.c: In function ‘bgmac_set_mac_address’:
> drivers/net/ethernet/broadcom/bgmac.c:1233:23: error: ‘struct bgmac’ has no member named ‘mac_addr’; did you mean ‘phyaddr’?
>   ether_addr_copy(bgmac->mac_addr, sa->sa_data);
>                        ^~
> drivers/net/ethernet/broadcom/bgmac.c:1234:38: error: ‘struct bgmac’ has no member named ‘mac_addr’; did you mean ‘phyaddr’?
>   bgmac_write_mac_address(bgmac, bgmac->mac_addr);
>                                       ^~

Well this is embarrassing.  I didn't rebase, even though I acked the
patch which changed it out from under me.  Sorry, I should've known
better.

Rebased, compiled, and tested patch coming shortly.  I appreciate your
patience.

Thanks,
Jon
