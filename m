From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Thu, 29 Sep 2016 07:51:35 -0700
Message-ID: <1475160695.28155.168.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160929035428.204355-1-tom@herbertland.com>
         <20160929035428.204355-5-tom@herbertland.com>
         <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
         <1475155080.28155.159.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S344d16SVhO+FhXpyL09k4vSuv45F-bff-nMeqS4H=p+tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36741 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933608AbcI2Ovh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 10:51:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so3665945pfb.3
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 07:51:37 -0700 (PDT)
In-Reply-To: <CALx6S344d16SVhO+FhXpyL09k4vSuv45F-bff-nMeqS4H=p+tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-29 at 10:08 -0400, Tom Herbert wrote:

> It addresses  the issue that Rick Jones pointed out was happening with
> XPS. When packets are sent for a flow that has no socket and XPS is
> enabled then each packet uses the XPS queue based on the running CPU.
> Since the thread sending on a flow can be rescheduled on different
> CPUs this is creating ooo packets. In this case the ooo is being
> caused by interaction with XPS.
> 

Nope, your patch does not address the problem properly.

I am not sure I want to spend more time explaining the issue.

Lets talk about this in Tokyo next week.
