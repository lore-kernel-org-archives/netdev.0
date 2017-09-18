From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/12] net: dsa: bcm_sf2: Defer port enabling to calling port_enable
Date: Mon, 18 Sep 2017 17:54:27 -0400
Message-ID: <87zi9r1xm4.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34680 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdIRV56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:57:58 -0400
In-Reply-To: <20170918214128.27896-5-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> There is no need to configure the enabled ports once in bcm_sf2_sw_setup() and
> then a second time around when dsa_switch_ops::port_enable is called, just do
> it when port_enable is called which is better in terms of power consumption and
> correctness.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
