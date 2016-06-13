From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v2 0/4] ovs: fix rtnl notifications on interface deletion
Date: Mon, 13 Jun 2016 12:39:16 -0700
Message-ID: <CAOrHB_DkcsW4_eEO_TQzJEVG-=EEajLwcPtddSqK-SCUMFyYww@mail.gmail.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
 <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jesse Gross <jesse@kernel.org>, linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:42500 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161119AbcFMTjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:39:21 -0400
Received: from mfilter42-d.gandi.net (mfilter42-d.gandi.net [217.70.178.172])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id A2039C5A56
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 21:39:19 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter42-d.gandi.net (mfilter42-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id YYtdnS8hOJr2 for <netdev@vger.kernel.org>;
	Mon, 13 Jun 2016 21:39:18 +0200 (CEST)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 41306C5A53
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 21:39:18 +0200 (CEST)
Received: by mail-io0-f177.google.com with SMTP id d2so41922108iof.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:39:18 -0700 (PDT)
In-Reply-To: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 1:31 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
>
> There was no rtnl notifications for interfaces (gre, vxlan, geneve) created
> by ovs. This problem is fixed by adjusting the creation path.
>
> v1 -> v2:
>  - add patch #1 and #4
>  - rework error handling in patch #2
>
>  drivers/net/geneve.c | 14 ++++++++++---
>  drivers/net/vxlan.c  | 58 ++++++++++++++++++++++++++++++----------------------
>  net/ipv4/ip_gre.c    | 14 ++++++++++---
>  3 files changed, 56 insertions(+), 30 deletions(-)
>

All patches looks good to me.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
