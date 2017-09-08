From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] tcp: fix a request socket leak
Date: Fri, 8 Sep 2017 15:59:23 -0700
Message-ID: <20170908225921.bxbgaldzt5fslpda@ast-mbp>
References: <1504899887.15310.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33742 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752999AbdIHW70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 18:59:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id m9so1890970pgd.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 15:59:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504899887.15310.95.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 08, 2017 at 12:44:47PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While the cited commit fixed a possible deadlock, it added a leak
> of the request socket, since reqsk_put() must be called if the BPF
> filter decided the ACK packet must be dropped.
> 
> Fixes: d624d276d1dd ("tcp: fix possible deadlock in TCP stack vs BPF filter")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> David, this is a stable candidate (linux-4.13 has this bug)

Thanks for the fix
Acked-by: Alexei Starovoitov <ast@kernel.org>
.. since the fix makes sense to me and as a reminder not to forget
to backport it as well :)
