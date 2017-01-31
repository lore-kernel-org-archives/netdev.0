From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Tue, 31 Jan 2017 10:36:47 -0500
Message-ID: <20170131153647.GA77071@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <michael.chan@broadcom.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34626 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdAaPhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:37:05 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so84613186wmi.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:36:59 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 08:47:47PM -0800, Alexei Starovoitov wrote:
> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
> > and add the basic infrastructure to support XDP.  The 9th patch adds
> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
> > completes the series with XDP_TX.
> 
> Looks great.
> Could you please share performance numbers ?

I'll post some later today.

> 
> Also please add something like:
>   if (prog && prog->xdp_adjust_head) {
>           netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>           return -EOPNOTSUPP;
>   }
> unless you plan to add adjut_head support until net-next closes.
> Note, it's must have for load balancer functionality.
