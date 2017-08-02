From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/1] constify tcp congestion
Date: Wed, 02 Aug 2017 01:13:09 -0700
Message-ID: <1501661589.25002.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170802024943.7517-1-sthemmin@microsoft.com>
         <20170802024943.7517-2-sthemmin@microsoft.com>
         <1501660563.25002.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34287 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752049AbdHBINP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 04:13:15 -0400
Received: by mail-pg0-f65.google.com with SMTP id y192so5723885pgd.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 01:13:14 -0700 (PDT)
In-Reply-To: <1501660563.25002.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-02 at 00:56 -0700, Eric Dumazet wrote:

> Also, I am not convinced this would be a good move, since you added an
> extra structure which is not const anyway.

Actually, this extra structure might be needed if we want to move the
tcp congestion sysctls to net namespace.
