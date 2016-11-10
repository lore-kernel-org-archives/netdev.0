From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Thu, 10 Nov 2016 19:33:47 +0100
Message-ID: <20161110193347.0e81d68b@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-3-git-send-email-pshelar@ovn.org>
        <20161109171018.69d08ff9@griffin>
        <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
        <20161110104703.7386ab29@griffin>
        <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46604 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755163AbcKJSdv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 13:33:51 -0500
In-Reply-To: <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016 10:10:09 -0800, Pravin Shelar wrote:
> I wanted to do same, that is free dst and skb in caller function. But
> that would need more changes due to discrepancy in IPv4 udp-tunnel and
> IPv6 udp-tunnel api. IPv4 works on route entry and IPv6 needs dst
> entry. so If caller frees dst-entry then I need additional variable to
> keep track of dst entry which is what I am trying to avoid.

Is additional variable really that bad? It's likely to be optimized by
the compiler and it will lead to less surprises. You obviously caught
me during review :-)

 Jiri
