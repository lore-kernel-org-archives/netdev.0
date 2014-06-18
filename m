From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix dual EMAC stall when
 connected to same switch
Date: Wed, 18 Jun 2014 15:01:29 +0200
Message-ID: <CAGm1_ktygja8o3wmnyErxJZk=_Wc7DHLUd1BPhjPb=JXKEDMqg@mail.gmail.com>
References: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:41220 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966308AbaFRNBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 09:01:50 -0400
Received: by mail-pb0-f54.google.com with SMTP id un15so722719pbc.41
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 06:01:49 -0700 (PDT)
In-Reply-To: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 1:51 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> In commit 629c9a8fd0bbdfc6d702526b327470166ec39c6b (drivers: net: cpsw: Add
> default vlan for dual emac case also), api cpsw_add_default_vlan() also
> changes the port vlan which is required to seperate the ports which results
> in the following behavior
>
> In Dual EMAC mode, when both the Etnernet connected is connected to same
> switch, it creates a loop in the switch and when a broadcast packet is
> received it is forwarded to the other port which stalls the whole switch
> and needs a reset/power cycle to the switch to recover. So intead of using
> the api, add only the default VLAN entry in dual EMAC case.
>
> Cc: Yegor Yefremov <yegorslists@googlemail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---

Thanks a lot. I have two interfaces connected to the same switch with
different subnets and everything is working.

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

Regards,
Yegor
