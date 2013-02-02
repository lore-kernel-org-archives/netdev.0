From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v9 net-next 02/12] bridge: Validate that vlan is permitted
 on ingress
Date: Sat, 2 Feb 2013 02:04:02 +0100
Message-ID: <CAHXqBFLTaPbReQh-vgc_kbBbUtEWOFyE2oq85boWoHFD2+Tm9w@mail.gmail.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:48989 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab3BBBEX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:04:23 -0500
Received: by mail-ob0-f174.google.com with SMTP id 16so4674580obc.19
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:04:23 -0800 (PST)
In-Reply-To: <1359748930-31475-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
> When a frame arrives on a port or transmitted by the bridge,
> if we have VLANs configured, validate that a given VLAN is allowed
> to enter the bridge.
[...]
> +static inline struct net_port_vlans *br_get_vlan_info(
> +                                               const struct net_brid=
ge *br)
> +{
> +       return rcu_dereference(br->vlan_info);
> +}
> +
> +static inline struct net_port_vlans *nbp_get_vlan_info(
> +                                               const struct net_brid=
ge_port *p)
> +{
> +       return rcu_dereference(p->vlan_info);
> +}

Those should go to patch #1.

Best Regards,
Micha=C5=82 Miros=C5=82aw
