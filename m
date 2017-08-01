From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Tue, 01 Aug 2017 00:18:27 -0700
Message-ID: <1501571907.1876.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170726170333.24580-1-mcroce@redhat.com>
         <1501495652.1876.17.camel@edumazet-glaptop3.roam.corp.google.com>
         <87wp6nerrj.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35705 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750852AbdHAHSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 03:18:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id r77so1651999wmd.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 00:18:29 -0700 (PDT)
In-Reply-To: <87wp6nerrj.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-01 at 02:17 -0400, Hannes Frederic Sowa wrote:

> We do account rmem as well as wmem allocated memory to the apropriate
> mem_cgs. In theory this should be okay.

Last time I checked, rmem was not memcg ready yet.

Can you describe the details ?

Thanks.
