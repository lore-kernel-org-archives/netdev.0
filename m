From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/7] nfp: compile flower vxlan tunnel metadata
 match fields
Date: Mon, 25 Sep 2017 21:35:25 +0300
Message-ID: <CAJ3xEMgs2d7dcktHfvx_iry8tBy8XK8n6E5W7J0pYPer9Xz_Kg@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com> <1506335021-32024-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:55269 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934344AbdIYSf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 14:35:27 -0400
Received: by mail-oi0-f46.google.com with SMTP id u130so7877195oib.11
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 11:35:26 -0700 (PDT)
In-Reply-To: <1506335021-32024-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> From: John Hurley <john.hurley@netronome.com>
>
> Compile ovs-tc flower vxlan metadata match fields for offloading. Only

anything in the npf kernel bits has direct relation to ovs? what?

> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
> @@ -52,8 +52,25 @@
>          BIT(FLOW_DISSECTOR_KEY_PORTS) | \
>          BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) | \
>          BIT(FLOW_DISSECTOR_KEY_VLAN) | \
> +        BIT(FLOW_DISSECTOR_KEY_ENC_KEYID) | \
> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) | \
> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) | \

this series takes care of IPv6 tunnels too?
