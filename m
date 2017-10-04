From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] bpf: remove global verifier state
Date: Tue, 03 Oct 2017 20:24:06 -0700
Message-ID: <1507087446.8061.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171003201452.elth55atpquesjjk@ast-mbp.dhcp.thefacebook.com>
         <20171004002025.28521-1-jakub.kicinski@netronome.com>
         <20171004025226.wutfwm6hcsj4zuph@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        daniel@iogearbox.net, dsahern@gmail.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, david.beckett@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37507 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdJDDYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 23:24:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id e69so11052978pfg.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 20:24:08 -0700 (PDT)
In-Reply-To: <20171004025226.wutfwm6hcsj4zuph@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-03 at 19:52 -0700, Alexei Starovoitov wrote:

> yep. looks great.
> Please test it and submit officially :)
> The commit aafe6ae9cee3 ("bpf: dynamically allocate digest scratch buffer")
> fixed the other case where we were relying on the above mutex.
> The only other spot to be adjusted is to add spin_lock/mutex or DO_ONCE() to
> bpf_get_skb_set_tunnel_proto() to protect md_dst init.
> imo that would be it.
> Daniel, anything else comes to mind?


16 MB of log (unswappable kernel memory) per active checker.

We might offer a way to oom hosts.
