From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/4] ip_tunnels: convert the mode field of
 ip_tunnel_info to flags
Date: Fri, 28 Aug 2015 10:29:55 -0700
Message-ID: <CALnjE+r4CW2+Rmi-qmnO+1oyQJ-YO_xiPVxO+3ygY9AEZnrWhw@mail.gmail.com>
References: <cover.1440771116.git.jbenc@redhat.com>
	<21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38171 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbbH1R34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 13:29:56 -0400
Received: by igyq3 with SMTP id q3so17562415igy.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 10:29:55 -0700 (PDT)
In-Reply-To: <21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 7:27 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The mode field holds a single bit of information only (whether the
> ip_tunnel_info struct is for rx or tx). Change the mode field to bit flags.
> This allows more mode flags to be added.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/vxlan.c        | 2 +-
>  include/net/dst_metadata.h | 1 -
>  include/net/ip_tunnels.h   | 9 ++-------
>  net/ipv4/ip_gre.c          | 2 +-
>  net/ipv4/route.c           | 2 +-
>  net/ipv6/route.c           | 2 +-

geneve module also needs to be updated.
