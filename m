From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in
 ip6_output
Date: Sat, 10 Jun 2017 07:56:53 -0700
Message-ID: <1497106613.736.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
         <20170609.150836.1427149901008136163.davem@davemloft.net>
         <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com>
         <87d1adge1i.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        lorenzo@google.com, edumazet@google.com, fengc@google.com
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34001 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752074AbdFJO4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 10:56:55 -0400
Received: by mail-pf0-f194.google.com with SMTP id u1so11652857pfg.1
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 07:56:55 -0700 (PDT)
In-Reply-To: <87d1adge1i.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 21:24 +0200, Bjørn Mork wrote:
> Chenbo Feng <chenbofeng.kernel@gmail.com> writes:
> 
> > This patch is still under working since it may have problem with
> > ip_fragment() call, did you applied it already? Should I send a revert
> > patch to you then?
> 
> It does? I initially thought so too, but looking closer I believe the
> ip6_copy_metadata() calls in ip6_fragment() takes care of it.

Indeed, this should be fine.
