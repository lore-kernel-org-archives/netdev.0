From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Performance issue with igb with lots of different src-ip addrs.
Date: Thu, 16 Mar 2017 19:35:31 -0700
Message-ID: <CAKgT0Ufwo-s0WUKu2kyELdx-CRHgmasEjyg+xnfgSGjo0dV_iQ@mail.gmail.com>
References: <58CB165F.7030302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38011 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752368AbdCQCfd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 22:35:33 -0400
Received: by mail-it0-f45.google.com with SMTP id m27so10753513iti.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 19:35:32 -0700 (PDT)
In-Reply-To: <58CB165F.7030302@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you include the pktgen script you are running?

Also when you say you are driving traffic through the bridge are you
sending from something external on the system or are you actually
directing the traffic from pktgen into the bridge directly?

- Alex

On Thu, Mar 16, 2017 at 3:49 PM, Ben Greear <greearb@candelatech.com> wrote:
> Hello,
>
> We notice that when using two igb ports as a bridge, if we use pktgen to
> drive traffic through the bridge and randomize (or use a very large range)
> for the source IP addr in pktgen, then performance of igb is very poor (like
> 150Mbps
> throughput instead of 1Gbps).  It runs right at line speed if we use same
> src/dest
> IP addr in pktgen.  So, seems it is related to lots of src/dest IP
> addresses.
>
> We see same problem when using pktgen to send to itself, and we see this in
> several different kernels.  We specifically tested bridge mode in this stock
> Fedora kernel:
>
>  Linux lfo350-59cc 4.9.13-101.fc24.x86_64 #1 SMP Tue Mar 7 23:48:32 UTC 2017
> x86_64 x86_64 x86_64 GNU/Linux
>
> e1000e does not show this problem in our testing.
>
> Any ideas what the issue might be and how to fix it?
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
