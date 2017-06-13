From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/4] net: dsa: Associate slave network device with CPU port
Date: Tue, 13 Jun 2017 15:23:50 -0400
Message-ID: <87vanzbsjd.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170613191725.26625-1-f.fainelli@gmail.com> <20170613191725.26625-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, john@phrozen.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38072 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751826AbdFMT0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 15:26:04 -0400
In-Reply-To: <20170613191725.26625-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In preparation for supporting multiple CPU ports with DSA, have the
> dsa_port structure know which CPU it is associated with. This will be
> important in order to make sure the correct CPU is used for transmission
> of the frames. If not for functional reasons, for performance (e.g: load
> balancing) and forwarding decisions.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
