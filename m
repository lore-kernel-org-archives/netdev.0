From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] lwtunnel: Add destroy state operation
Date: Thu, 13 Oct 2016 22:58:04 -0700
Message-ID: <580073EC.2030802@cumulusnetworks.com>
References: <20161014005743.288956-1-tom@herbertland.com> <20161014005743.288956-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35726 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756708AbcJNF63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 01:58:29 -0400
Received: by mail-pa0-f50.google.com with SMTP id qn10so44533915pac.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:58:08 -0700 (PDT)
In-Reply-To: <20161014005743.288956-2-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/16, 5:57 PM, Tom Herbert wrote:
> Users of lwt tunnels may set up some secondary state in build_state
> function. Add a corresponding destroy_state function to allow users to
> clean up state. This destroy state function is called from lwstate_free.
> Also, we now free lwstate using kfree_rcu so user can assume structure
> is not freed before rcu.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

this will be useful elsewhere too, thanks!.
