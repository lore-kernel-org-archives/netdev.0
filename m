From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 23/26] sh_eth: constify local structures
Date: Mon, 12 Sep 2016 10:55:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609121054420.3049@hadrien>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr> <1473599168-30561-24-git-send-email-Julia.Lawall@lip6.fr> <cb443416-4fb9-5593-2529-66211299c9a8@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:42339 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751579AbcILIzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:55:38 -0400
In-Reply-To: <cb443416-4fb9-5593-2529-66211299c9a8@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 11 Sep 2016, Sergei Shtylyov wrote:

> On 09/11/2016 04:06 PM, Julia Lawall wrote:
> > For structure types defined in the same file or local header files, find
> > top-level static structure declarations that have the following
> > properties:
> > 1. Never reassigned.
>
>   Really?
>
> > 2. Address never taken
>
>   Really?
>
> > 3. Not passed to a top-level macro call
> > 4. No pointer or array-typed field passed to a function or stored in a
> > variable.
> > Declare structures having all of these properties as const.
> >
> > Done using Coccinelle.
> > Based on a suggestion by Joe Perches <joe@perches.com>.
> >
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>
>    NAK, see sh_eth_set_default_cpu_data().

Thanks for the feedback.  I will check on why this slipped through.
Perhaps it is a variability (ifdef) problem.

julia

>
> MBR, Sergei
>
>
