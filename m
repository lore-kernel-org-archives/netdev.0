From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: fdb dump: optimize by saving last
 interface markers
Date: Fri, 02 Sep 2016 06:47:28 -0700
Message-ID: <1472824048.5439.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
         <1472792070.5439.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKoUAr=kOjb4e_JE3-z=C+8uDjpTa8UdPhys15RooSjTSy=giQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        wkok@cumulusnetworks.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        makita.toshiaki@lab.ntt.co.jp,
        =?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>,
        idosch@mellanox.com, Netdev <netdev@vger.kernel.org>,
        minoura@valinux.co.jp, Dept-GELinuxNICDev@qlogic.com
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35214 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbcIBNrb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:47:31 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so42668397pfd.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 06:47:31 -0700 (PDT)
In-Reply-To: <CAKoUAr=kOjb4e_JE3-z=C+8uDjpTa8UdPhys15RooSjTSy=giQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 14:14 +0300, Rami Rosen wrote:
> Hi Eric,
> 
> Nice catch!
> This warning does not occur under certain gcc versions.
> For example, gcc 4.8.4 (ubuntu 14.04);  it does occur, for example,
> under gcc 5.3.1 for example (Fedora 24).
> 
> I just sent a patch to fix this.
> 

Thanks Rami for taking care of this.

Please add in your future submissions any relevant attributions ;)
