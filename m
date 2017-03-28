From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Tue, 28 Mar 2017 14:13:53 -0400
Message-ID: <87lgrpe0bi.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44934 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753112AbdC1SPS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:15:18 -0400
In-Reply-To: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> The ATU ageing time value programmed in the switch is rounded up to the
> nearest multiple of its coefficient (variable depending on the model.)
>
> Add a debug message to inform the user about the exact programmed value.
>
> On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
> while on 6390 we get "AgeTime set to 0x05 (18750 ms)".
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Can you pick this patch?

Thanks,

        Vivien
