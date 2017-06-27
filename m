From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tc: custom qdisc pkt size translation table
Date: Tue, 27 Jun 2017 10:55:55 -0700
Message-ID: <1498586155.736.138.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170627162917.20244-1-Robert.McCabe@rockwellcollins.com>
         <1498582512.736.119.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA0ESdrH+_1OhkuL7wmjjM-zNqY0o4qp5qDdfrNCR9LENCqbQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert McCabe <robert.mccabe@rockwellcollins.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33897 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdF0Rz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 13:55:57 -0400
Received: by mail-pf0-f181.google.com with SMTP id s66so20157805pfs.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 10:55:56 -0700 (PDT)
In-Reply-To: <CAA0ESdrH+_1OhkuL7wmjjM-zNqY0o4qp5qDdfrNCR9LENCqbQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-27 at 12:37 -0500, Robert McCabe wrote:
> Yeah, sorry didn't even think about that.
> I guess my first question would be is there another way via the
> iproute2 project where a user could
> configure the stab->data pkt size translation table used in the
> __qdisc_calculate_pkt_len method
> in the kernel source (net/sched/sched_api.c)?
> 
> Also, let's say I went ahead and made the added TC_LINK_LAYER_CUSTOM
> to the include/uapi/linux/pkt_sched.h
> file in the kernel source ... would I also need to make the same
> change in include/uapi/linux/pkt_sched.h in
> the iproute2 source?
> 
> Do you recommend an alternative (more elegant) approach to what I'm
> trying to accomplish?

Note that since you probably want to be able to dump the table
(tc -s -d qdisc show ), you might need a kernel change anyway.

Then the iproute2 change would be a companion.
