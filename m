From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/2] netvsc: performance regressions in
 net-next
Date: Mon, 20 Mar 2017 13:31:52 -0700
Message-ID: <20170320133152.52a7da53@xeon-e3>
References: <20170320202805.19362-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33321 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbdCTUcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 16:32:00 -0400
Received: by mail-pf0-f171.google.com with SMTP id e129so31757947pfh.0
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 13:31:59 -0700 (PDT)
In-Reply-To: <20170320202805.19362-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Mar 2017 13:28:03 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> Fix for performance regression introduced with NAPI change;
> and followup cleanup of vmbus core code.
> 
> Stephen Hemminger (2):
>   netvsc: fix NAPI performance regression
>   vmbus: no longer expose iterator internals
> 
>  drivers/hv/ring_buffer.c        | 51 +++++++++++++++++++++--------------------
>  drivers/net/hyperv/hyperv_net.h |  1 +
>  drivers/net/hyperv/netvsc.c     | 41 +++++++++++++++------------------
>  include/linux/hyperv.h          | 22 +-----------------
>  4 files changed, 46 insertions(+), 69 deletions(-)
> 

Drop this version.  The code is correct the second patch causes
clashes with some later patches. Will resend.
