From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 2/3] bnxt_en: Log a message, if enabling
 NTUPLE filtering fails.
Date: Wed, 27 Jul 2016 01:04:25 -0700
Message-ID: <CACKFLinix1aM_YbTMEhN6zX4fR80vKShDebBkTVxD-zk=cXaGg@mail.gmail.com>
References: <1469464417-786-1-git-send-email-michael.chan@broadcom.com>
 <1469464417-786-3-git-send-email-michael.chan@broadcom.com> <CAD=hENeGisVP1Nx87_V5kW5y-YAaYF7Xj_aakEz0Cc6mswJqdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36843 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbcG0IE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 04:04:26 -0400
Received: by mail-oi0-f52.google.com with SMTP id w18so7074452oiw.3
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 01:04:26 -0700 (PDT)
In-Reply-To: <CAD=hENeGisVP1Nx87_V5kW5y-YAaYF7Xj_aakEz0Cc6mswJqdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 12:31 AM, zhuyj <zyjzyj2000@gmail.com> wrote:
>  +       if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) {
>    <-----Does this happen very rarely? If so,
>
> if (unlikely(vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) { is better?

This is not in the fast path, so it doesn't matter.

>
> +               netdev_warn(bp->dev,
> +                           "Not enough resources to support NTUPLE
> filters, enough resources for up to %d rx rings\n",
> +                           min(pf->max_rsscos_ctxs - 1, pf->max_vnics - 1));
>                 return false;
> +       }
>
