From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: Do not check for NULL dst in tag parsers
Date: Fri, 07 Apr 2017 16:53:30 -0400
Message-ID: <878tncvt11.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170407204154.9651-1-f.fainelli@gmail.com> <20170407204154.9651-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42580 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754070AbdDGUzF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:55:05 -0400
In-Reply-To: <20170407204154.9651-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> dsa_switch_rcv() already tests for dst == NULL, so there is no need to duplicate
> the same check within the tag receive functions.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
