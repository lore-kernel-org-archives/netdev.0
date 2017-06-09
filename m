From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in ip6_output
Date: Fri, 09 Jun 2017 21:24:25 +0200
Message-ID: <87d1adge1i.fsf@miraculix.mork.no>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
        <20170609.150836.1427149901008136163.davem@davemloft.net>
        <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        lorenzo@google.com, edumazet@google.com, fengc@google.com
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45215 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751561AbdFITYe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 15:24:34 -0400
In-Reply-To: <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com> (Chenbo Feng's
        message of "Fri, 9 Jun 2017 12:13:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chenbo Feng <chenbofeng.kernel@gmail.com> writes:

> This patch is still under working since it may have problem with
> ip_fragment() call, did you applied it already? Should I send a revert
> patch to you then?

It does? I initially thought so too, but looking closer I believe the
ip6_copy_metadata() calls in ip6_fragment() takes care of it.



Bj=C3=B8rn
