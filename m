From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/3 v2] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Wed, 10 Jun 2015 19:12:33 -0700
Message-ID: <CAE4R7bCy1bZ1A7tUNOA9H2GqwZhjWSqtjzs=GLxUUyNT_3+=gA@mail.gmail.com>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com> <1433918841-15576-3-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36463 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbFKCMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 22:12:54 -0400
Received: by qkx62 with SMTP id 62so34128302qkx.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 19:12:53 -0700 (PDT)
In-Reply-To: <1433918841-15576-3-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015 at 11:47 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:

>  /* /proc/sys/net/ipv4/netfilter */
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 7e7746a..c9d0a0e 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
>         { CTL_INT,      NET_IPV4_CONF_NOPOLICY,                 "disable_policy" },
>         { CTL_INT,      NET_IPV4_CONF_FORCE_IGMP_VERSION,       "force_igmp_version" },
>         { CTL_INT,      NET_IPV4_CONF_PROMOTE_SECONDARIES,      "promote_secondaries" },
> +       { CTL_INT,      NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,      "ignore_routes_with_linkdown" },

Would "route_ignore_linkdown_nexthops" be a more accurate name?  The
patch marks link-downed nexthops to be ignored, not the route,
correct?

s/NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN/NET_IPV4_CONF_ROUTE_IGNORE_LINKDOWN_NEXTHOPS
