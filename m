From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: Avoid regenerating skb flow hash
 unless necessary
Date: Wed, 18 Jan 2017 13:13:13 -0800
Message-ID: <1484773993.16328.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170118210428.24006-1-acollins@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33687 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdARViQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 16:38:16 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so2291018pgd.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 13:36:45 -0800 (PST)
In-Reply-To: <20170118210428.24006-1-acollins@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-18 at 14:04 -0700, Andrew Collins wrote:
> The fq_codel qdisc currently always regenerates the skb flow hash.
> This wastes some cycles and prevents flow seperation in cases where
> the traffic has been encrypted and can no longer be understood by the
> flow dissector.
> 
> Change it to use the prexisting flow hash if one exists, and only
> regenerate if necessary.
> 
> Signed-off-by: Andrew Collins <acollins@cradlepoint.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
