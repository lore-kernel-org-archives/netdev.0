From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 09/11] net: Rearrange dst_entry layout to avoid
 useless padding.
Date: Tue, 31 Oct 2017 11:49:54 -0700
Message-ID: <1509475794.3828.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-10-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:52267 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932532AbdJaSt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:49:56 -0400
Received: by mail-io0-f195.google.com with SMTP id f20so957559ioj.9
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:49:56 -0700 (PDT)
In-Reply-To: <20171031141054.9954-10-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> We have padding to try and align the refcount on a separate cache
> line.  But after several simplifications the padding has increased
> substantially.
> 
> So now it's easy to change the layout to get rid of the padding
> entirely.
> 
> We group the write-heavy __refcnt and __use with less often used
> items such as the rcu_head and the error code.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
