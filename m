From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Thu, 31 Aug 2017 15:51:11 +0200
Message-ID: <87fuc7ong0.fsf@stressinduktion.org>
References: <20170830230409.15176-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59921 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751034AbdHaNvV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 09:51:21 -0400
In-Reply-To: <20170830230409.15176-1-saeedm@mellanox.com> (Saeed Mahameed's
        message of "Thu, 31 Aug 2017 02:04:06 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saeed Mahameed <saeedm@mellanox.com> writes:

> The first patch from Gal and Ariel provides the mlx5 driver support for
> ConnectX capability to perform IP version identification and matching in
> order to distinguish between IPv4 and IPv6 without the need to specify the
> encapsulation type, thus perform RSS in MPLS automatically without
> specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
> classification for inner GRE RSS.

I don't think this is legal at all or did I misunderstood something?

<https://tools.ietf.org/html/rfc3032#section-2.2>

Thanks,
Hannes
