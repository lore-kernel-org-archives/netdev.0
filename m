From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/2] fib4 offload: notifier to let hw to be
 aware of all prefixes
Date: Mon, 19 Sep 2016 23:18:39 -0700
Message-ID: <CAJieiUgmsBrw9huu7bmZj9tyUQU-m+8eZzXLs1LsQwttcVDa0Q@mail.gmail.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <fc177125-a9b8-fcce-281b-5fdc25639944@gmail.com> <57DF2041.3040509@cumulusnetworks.com>
 <20160919061454.GC1846@nanopsycho.orion> <57DFFD4A.6070403@cumulusnetworks.com>
 <20160919151549.GE1846@nanopsycho.orion> <57E0CDFB.2020704@cumulusnetworks.com>
 <20160920060239.GC1843@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        John Linville <linville@tuxdriver.com>,
        Thomas Graf <tgraf@suug.ch>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Scott Feldman <sfeldma@gmail.com>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Eric Dumazet <edumazet@google.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Vivien Didelot <vivien.didelot@
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35619 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754062AbcITGSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:18:41 -0400
Received: by mail-vk0-f45.google.com with SMTP id g9so10752211vkg.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 23:18:41 -0700 (PDT)
In-Reply-To: <20160920060239.GC1843@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 11:02 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Sep 20, 2016 at 07:49:47AM CEST, roopa@cumulusnetworks.com wrote:

[snip]

>>
>>Do you see any scale problems with using notifiers ?. as you know these ascis can scale to
>>32k-128k routes.
>
> I don't see any problem there. What do you think might be wrong?
>

we had seen some overheads with link notifiers in older kernels with
large number of links flaps.
But that could have been due to rtnl lock. don't have any more data
than that. so, ignore that.
I don't see anything obvious from perf perspective....rtnl is already
held. but, thought i did just ask.
