From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Wed, 19 Apr 2017 07:13:51 -0700
Message-ID: <1492611231.10587.165.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35996 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761087AbdDSONz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 10:13:55 -0400
Received: by mail-it0-f67.google.com with SMTP id a140so3161837ita.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 07:13:54 -0700 (PDT)
In-Reply-To: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 11:13 +0100, James Hughes wrote:
> The driver was failing to check that the SKB wasn't cloned
> before adding checksum data.
> Replace existing handling to extend/copy the header buffer
> with skb_cow_head.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks James
