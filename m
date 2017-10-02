From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] bridge: neigh msg proxy and flood
 suppression support
Date: Mon, 2 Oct 2017 07:49:09 -0700
Message-ID: <CAJieiUim2XLMGAomb3S5AeWfYqjxV_raetedWcA_PBiaGPRHWg@mail.gmail.com>
References: <1506919018-27875-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:47605 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdJBOtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 10:49:11 -0400
Received: by mail-vk0-f42.google.com with SMTP id h63so2985234vka.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 07:49:10 -0700 (PDT)
In-Reply-To: <1506919018-27875-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 1, 2017 at 9:36 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This series implements arp and nd suppression in the bridge
> driver for ethernet vpns. It implements rfc7432, section 10
> https://tools.ietf.org/html/rfc7432#section-10
> for ethernet VPN deployments. It is similar to the existing
> BR_ARP_PROXY flag but has a few semantic differences to conform
> to EVPN standard. In case of EVPN, it is mainly used to avoid flooding to
> tunnel ports like vxlan/mpls. Unlike the existing flags it suppresses flood
> of all neigh discovery packets (arp, nd) to tunnel ports.
>
> Roopa Prabhu (3):
>   bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd
>     flood
>   neigh arp suppress first
>   bridge: suppress nd messages from going to BR_NEIGH_SUPPRESS ports
>

pls ignore, shows conflict applying over recent net-next bridge
changes. Will rebase and submit v2.
