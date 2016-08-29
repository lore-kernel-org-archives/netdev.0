From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sky2: use napi_complete_done
Date: Mon, 29 Aug 2016 11:35:15 -0700
Message-ID: <1472495715.14381.268.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160829101637.4f0663e5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34520 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754013AbcH2SfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 14:35:17 -0400
Received: by mail-pa0-f42.google.com with SMTP id fi15so51979609pac.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 11:35:17 -0700 (PDT)
In-Reply-To: <20160829101637.4f0663e5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-08-29 at 10:16 -0700, Stephen Hemminger wrote:
> Update the sky2 driver to pass number of packets done to NAPI.
> The driver was never updated when napi_complete_done was added.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
