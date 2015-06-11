From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 2/3 v3] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Thu, 11 Jun 2015 11:57:47 +0900
Message-ID: <5578F92B.8060604@miraclelinux.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com> <1433990233-958-3-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:40766 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751453AbbFKC5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 22:57:54 -0400
Received: by mail-pd0-f179.google.com with SMTP id m12so48879082pdj.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 19:57:53 -0700 (PDT)
In-Reply-To: <1433990233-958-3-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Andy Gospodarek wrote:
> This feature is only enabled with the new per-interface or ipv4 global
> sysctls called 'ignore_routes_with_linkdown'.
> 
> net.ipv4.conf.all.ignore_routes_with_linkdown = 0
> net.ipv4.conf.default.ignore_routes_with_linkdown = 0
> net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
:
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> ---
:
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 7e7746a..c9d0a0e 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -253,6 +253,7 @@ static const struct bin_table bin_net_ipv4_conf_vars_table[] = {
>  	{ CTL_INT,	NET_IPV4_CONF_NOPOLICY,			"disable_policy" },
>  	{ CTL_INT,	NET_IPV4_CONF_FORCE_IGMP_VERSION,	"force_igmp_version" },
>  	{ CTL_INT,	NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
> +	{ CTL_INT,	NET_IPV4_CONF_IGNORE_ROUTES_WITH_LINKDOWN,	"ignore_routes_with_linkdown" },
>  	{}
>  };
>  

Please do not add new binary sysctl knob. Thank you.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
