From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] geneve: fix ip_hdr_len reserved for geneve6 tunnel.
Date: Sun, 27 Nov 2016 21:57:31 -0800
Message-ID: <CAOrHB_Dr+jKDKSY9FOqhoLkLZCqupmHm6pv8tAT773AXOaRWPw@mail.gmail.com>
References: <1480310818-78456-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Jiri Benc <jbenc@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:54031 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbcK1F5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 00:57:36 -0500
In-Reply-To: <1480310818-78456-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 9:26 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> It shold reserved sizeof(ipv6hdr) for geneve in ipv6 tunnel.
>
> Fixes: c3ef5aa5e5 ('geneve: Merge ipv4 and ipv6 geneve_build_skb()')
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Thanks for fix.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
