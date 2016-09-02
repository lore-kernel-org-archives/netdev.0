From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: fdb dump: optimize by saving last
 interface markers
Date: Fri, 2 Sep 2016 14:14:26 +0300
Message-ID: <CAKoUAr=kOjb4e_JE3-z=C+8uDjpTa8UdPhys15RooSjTSy=giQ@mail.gmail.com>
References: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com> <1472792070.5439.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        wkok@cumulusnetworks.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        makita.toshiaki@lab.ntt.co.jp,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        idosch@mellanox.com, Netdev <netdev@vger.kernel.org>,
        minoura@valinux.co.jp, Dept-GELinuxNICDev@qlogic.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34390 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbcIBLO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 07:14:29 -0400
Received: by mail-lf0-f42.google.com with SMTP id p41so62641147lfi.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 04:14:28 -0700 (PDT)
In-Reply-To: <1472792070.5439.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Nice catch!
This warning does not occur under certain gcc versions.
For example, gcc 4.8.4 (ubuntu 14.04);  it does occur, for example,
under gcc 5.3.1 for example (Fedora 24).

I just sent a patch to fix this.

Regards,
Rami Rosen
