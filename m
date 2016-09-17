From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v10 2/3] net: core: Add offload stats to if_stats_msg
Date: Sat, 17 Sep 2016 13:55:20 +0300
Message-ID: <41DD7712-E49A-4810-AFA5-F55981B4DDA0@cumulusnetworks.com>
References: <1474031138-2065-1-git-send-email-jiri@resnulli.us> <1474031138-2065-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
        eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35314 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbcIQKzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 06:55:23 -0400
Received: by mail-wm0-f41.google.com with SMTP id l132so76226690wmf.0
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 03:55:23 -0700 (PDT)
In-Reply-To: <1474031138-2065-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 16, 2016, at 4:05 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>=20
> From: Nogah Frankel <nogahf@mellanox.com>
>=20
> Add a nested attribute of offload stats to if_stats_msg
> named IFLA_STATS_LINK_OFFLOAD_XSTATS.
> Under it, add SW stats, meaning stats only per packets that went via
> slowpath to the cpu, named IFLA_OFFLOAD_XSTATS_CPU_HIT.
>=20
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> include/uapi/linux/if_link.h |   9 ++++
> net/core/rtnetlink.c         | 111 =
+++++++++++++++++++++++++++++++++++++++++--
> 2 files changed, 116 insertions(+), 4 deletions(-)
>=20
>=20

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
