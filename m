From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: NFCT writing localhost conntrack entries too
Date: Wed, 30 Aug 2017 13:27:33 +0530
Message-ID: <CAA5aLPicZ4Ax0kQoVE26ey-mAgBXu7NemENzM+d6dLk=647QcQ@mail.gmail.com>
References: <CAA5aLPhyBj=ZE1OPuDw-vKqpceHZ2r8EdPiSdW66V74ya_HCdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36124 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdH3H5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 03:57:35 -0400
Received: by mail-pg0-f49.google.com with SMTP id r133so17900739pgr.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 00:57:34 -0700 (PDT)
In-Reply-To: <CAA5aLPhyBj=ZE1OPuDw-vKqpceHZ2r8EdPiSdW66V74ya_HCdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anybody ?

On Tue, Aug 29, 2017 at 3:53 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> With ulog/nflog, NFCT plugin, is it possible to not log entries with src ip
> as 127.0.0.1
>
> I can see following options in ulogd.conf
> #accept_src_filter=192.168.1.0/24,1:2::/64 # source ip of connection
> must belong to these networks
> #accept_dst_filter=192.168.1.0/24 # destination ip of connection must
> belong to these networks
> #accept_proto_filter=tcp,sctp # layer 4 proto of connections
>
>
> ... but what I am looking for is like deny_src_filter.
>
> Is it possible?
