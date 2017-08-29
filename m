From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Tue, 29 Aug 2017 11:01:29 -0700
Message-ID: <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
         <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825.211905.920493778125075310.davem@davemloft.net>
         <1503751671.11498.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <deb227c9-728a-bd98-f282-1478d71353a8@gmail.com>
         <353aa37f-c62b-f5af-8c89-f67af6509497@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        pabeni@redhat.com, willemb@google.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35951 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2SBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:01:32 -0400
Received: by mail-pf0-f174.google.com with SMTP id z87so12280246pfi.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:01:32 -0700 (PDT)
In-Reply-To: <353aa37f-c62b-f5af-8c89-f67af6509497@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 10:53 -0700, Florian Fainelli wrote:
> On 08/26/2017 11:56 AM, Florian Fainelli wrote:
> > 
> > 
> > On 08/26/2017 05:47 AM, Eric Dumazet wrote:
> >> On Fri, 2017-08-25 at 21:19 -0700, David Miller wrote:
> >>
> >>> Agreed, but the ARP resolution queue really needs to scale it's backlog
> >>> to the physical technology it is attached to.
> >> Yes, last time (in 2011) we increased the old limit of 3 packets :/
> >>
> >> We probably should match sysctl_wmem_max so that a single socket
> >> provider would hit its sk_sndbuf limit
> 
> Eric, do you want to post this as a formal patch? I don't think I
> understand these tunables enough to provide a good commit message
> anyways. Thanks!

I will post it today.

I was out of the office yesterday, rafting on the south fork of American
River ;)


This will target net-next.

Thanks.
