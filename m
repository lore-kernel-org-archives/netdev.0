From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v9 net-next 05/12] bridge: Add the ability to configure pvid
Date: Sat, 2 Feb 2013 02:04:14 +0100
Message-ID: <CAHXqBFKXEHjghyDe4UQs4inH55UzWcsz+eWAXR4qFiM7+4yVxw@mail.gmail.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-6-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:52727 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757093Ab3BBBEf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:04:35 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so4024824oag.12
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:04:34 -0800 (PST)
In-Reply-To: <1359748930-31475-6-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
> A user may designate a certain vlan as PVID.  This means that
> any ingress frame that does not contain a vlan tag is assigned to
> this vlan and any forwarding decisions are made with this vlan in min=
d.
[...]
>  struct net_port_vlans {
>         u16                             port_idx;
> +       u16                             pvid;

I'm confused about the implementation. I would expect pvid field in
net_bridge_port and adding a tag if it isn't there on ingress path.
The rest would be just like without PVIDs. But here you pvid field to
net_port_vlans, and don't do anything with it in receive nor transmit
path. Does it work? What am I missing?

Best Regards,
Micha=C5=82 Miros=C5=82aw
