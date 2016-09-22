From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: rtnl_register in net_ns_init need rtnl_lock
Date: Thu, 22 Sep 2016 07:48:06 -0700
Message-ID: <1474555686.23058.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
         <1474549384.23058.94.camel@edumazet-glaptop3.roam.corp.google.com>
         <4c1b9aba-e6e8-babc-1bbe-aef2bc0bca53@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34819 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754311AbcIVOsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 10:48:08 -0400
Received: by mail-pf0-f179.google.com with SMTP id z123so31422968pfz.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:48:08 -0700 (PDT)
In-Reply-To: <4c1b9aba-e6e8-babc-1bbe-aef2bc0bca53@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 15:41 +0200, Hannes Frederic Sowa wrote:

> I found this during working on the file and actually saw no live issues
> (belonged to another series which I just split up).
> 
> I don't think it is a big issue but wanted the writes to the
> rtnl_msg_handlers array to be strictly serialized. I was working on
> adding this to other places, too. Maybe better for net-next even?

Sure, and you probably could enforce an ASSERT_RTNL() in rtnl_register()
to catch all offenders.
