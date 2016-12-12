From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: Fix opps when adding vlan bridge
Date: Mon, 12 Dec 2016 08:15:48 -0500
Message-ID: <87pokxnv97.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48300 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbcLLNP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:15:59 -0500
In-Reply-To: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> A port is not necessarily assigned to a netdev. And a port does not
> need to be a member of a bridge. So when iterating over all ports,
> check before using the netdev and bridge_dev for a port. Otherwise we
> dereference a NULL pointer.
>
> Fixes: da9c359e19f0 ("net: dsa: mv88e6xxx: check hardware VLAN in use")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
