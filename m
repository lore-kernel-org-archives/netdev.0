From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 12/12] net: dsa: bcm_sf2: Utilize b53_{enable,disable}_port
Date: Tue, 19 Sep 2017 10:45:50 -0400
Message-ID: <87a81qsq5d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170919021947.8971-1-f.fainelli@gmail.com> <20170919021947.8971-13-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40682 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750862AbdISOtW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:49:22 -0400
In-Reply-To: <20170919021947.8971-13-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Export b53_{enable,disable}_port and use these two functions in
> bcm_sf2_port_setup and bcm_sf2_port_disable. The generic functions
> cannot be used without wrapping because we need to manage additional
> switch integration details (PHY, Broadcom tag etc.).
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
