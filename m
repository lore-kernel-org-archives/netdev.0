From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] net: diag: slightly refactor the
 inet_diag_bc_audit error checks.
Date: Wed, 24 Aug 2016 08:16:24 -0600
Message-ID: <b38f36e7-cbdc-2760-0911-9f6f5c83193d@cumulusnetworks.com>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net, ek@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34765 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754552AbcHXOQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 10:16:36 -0400
Received: by mail-pa0-f41.google.com with SMTP id fi15so6976076pac.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 07:16:26 -0700 (PDT)
In-Reply-To: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/16 12:46 AM, Lorenzo Colitti wrote:
> This simplifies the code a bit and also allows inet_diag_bc_audit
> to send to userspace an error that isn't EINVAL.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv4/inet_diag.c | 28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
