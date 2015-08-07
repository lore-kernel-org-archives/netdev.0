From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v4 3/4] openvswitch: Use regular GRE net_device
 instead of vport
Date: Fri, 7 Aug 2015 16:05:29 -0700
Message-ID: <CAEP_g=_7ki6XvR274GcMdBbca-BpBxP=s8nbDnxK_TQL1FYCaA@mail.gmail.com>
References: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:32954 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946324AbbHGXFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 19:05:55 -0400
Received: by lbbyj8 with SMTP id yj8so68607425lbb.0
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2015 16:05:48 -0700 (PDT)
In-Reply-To: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 5, 2015 at 8:12 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
> index 1584040..c56f4d4 100644
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@ -34,7 +34,6 @@ config OPENVSWITCH
>  config OPENVSWITCH_GRE
>         tristate "Open vSwitch GRE tunneling support"
>         depends on OPENVSWITCH
> -       depends on NET_IPGRE_DEMUX
>         default OPENVSWITCH
>         ---help---
>           If you say Y here, then the Open vSwitch will be able create GRE

Doesn't this need to depend on NET_IPGRE now instead?
