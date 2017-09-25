From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net] net: dsa: mv88e6xxx: Allow dsa and cpu ports in multiple vlans
Date: Mon, 25 Sep 2017 17:34:53 -0400
Message-ID: <87mv5io41u.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506375140-2853-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53806 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934892AbdIYVia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:38:30 -0400
In-Reply-To: <1506375140-2853-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Ports with the same VLAN must all be in the same bridge. However the
> CPU and DSA ports need to be in multiple VLANs spread over multiple
> bridges. So exclude them when performing this test.
>
> Fixes: b2f81d304cee ("net: dsa: add CPU and DSA ports as VLAN members")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
