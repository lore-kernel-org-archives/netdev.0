From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: drop non loopback packets claiming to
 originate from ::1
Date: Fri, 14 Apr 2017 12:10:32 -0700
Message-ID: <1492197032.10587.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170414182243.24506-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33795 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdDNTKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:10:35 -0400
Received: by mail-pf0-f169.google.com with SMTP id c198so43798506pfc.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 12:10:35 -0700 (PDT)
In-Reply-To: <20170414182243.24506-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-14 at 20:22 +0200, Florian Westphal wrote:
> We lack a saddr check for ::1. This causes security issues e.g. with acls
> permitting connections from ::1 because of assumption that these originate
> from local machine.
> 
> Assuming a source address of ::1 is local seems reasonable.
> RFC4291 doesn't allow such a source address either, so drop such packets.
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/ipv6/ip6_input.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
