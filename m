From: Andrew Collins <acollins@cradlepoint.com>
Subject: Re: [PATCH] Add netdev all_adj_list refcnt propagation to fix panic
Date: Wed, 28 Sep 2016 13:04:42 -0600
Message-ID: <715a8d0a-9245-fd83-bf58-70f863c721f7@cradlepoint.com>
References: <1475086011-5588-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <vfalico@gmail.com>, <nikolay@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0134.outbound.protection.outlook.com ([104.47.40.134]:54848
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752507AbcI1Wh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 18:37:26 -0400
In-Reply-To: <1475086011-5588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 12:06 PM, David Ahern wrote:
> Andrew Collins posted this patch as RFC in March:
>     http://patchwork.ozlabs.org/patch/603101/
>
> It has apparently fallen through the cracks and never applied.
>
> It solves a refcnt problem (thanks Nik for pointing out this patch)

I have been running the patch in production for the past few months without issue, in spite of my concerns about the potential side effects of the change.  That said, I suspect my use cases are a subset of yours.

If nobody has a better fix yet, I'm happy to respin this patch as non-RFC with proper signoff.

Regards,
Andrew Collins
