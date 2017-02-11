From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 0/2] net: ethernet: ti: cpsw: fix susp/resume
Date: Sat, 11 Feb 2017 02:01:16 +0200
Message-ID: <20170211000115.GA3037@khorivan>
References: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <20170209.172126.155005439329995220.davem@davemloft.net>
 <20170209225423.GA15853@khorivan>
 <20170209.204507.954952367013216032.davem@davemloft.net>
 <ffaeb9fe-fd0a-3735-9f72-dded96de6e56@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mugunthanvnm@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org, AStarikovskiy@topcon.com
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33070 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752107AbdBKAHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 19:07:52 -0500
Received: by mail-lf0-f52.google.com with SMTP id x1so30305547lff.0
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 16:07:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ffaeb9fe-fd0a-3735-9f72-dded96de6e56@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 12:05:07PM -0600, Grygorii Strashko wrote:
> 
> 
> On 02/09/2017 07:45 PM, David Miller wrote:
> >From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> >Date: Fri, 10 Feb 2017 00:54:24 +0200
> >
> >>On Thu, Feb 09, 2017 at 05:21:26PM -0500, David Miller wrote:
> >>>From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> >>>Date: Thu,  9 Feb 2017 02:07:34 +0200
> >>>
> >>>>These two patches fix suspend/resume chain.
> >>>
> >>>Patch 2 doesn't apply cleanly to the 'net' tree, please
> >>>respin this series.
> >>
> >>Strange, I've just checked it on net-next/master, it was applied w/o any
> >>warnings.
> >
> >It makes no sense to test "net-next" when I am telling you that it is
> >the "net" tree it doesn't apply to.
> >
> >This is a bug fix, so it should be targetting the "net" tree.
> >
> 
> Looks like the first fix is for net, but the second one is for net-next
> I do not see
> 03fd01ad0eead23eb79294b6fb4d71dcac493855
> "net: ethernet: ti: cpsw: don't duplicate ndev_running"
> in net.

There is dependency, both for net-next and only first is for net tree

> 
> -- 
> regards,
> -grygorii
