From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/4] net: dsa: Allow the DSA driver to indicate the tag protocol
Date: Mon, 22 Aug 2016 10:32:04 -0400
Message-ID: <8760qs98nv.fsf@ketchup.mtl.sfl>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch> <1471874464-16142-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50649 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754794AbcHVOcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:32:08 -0400
In-Reply-To: <1471874464-16142-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> DSA drivers may drive different families of switches which need
> different tag protocol. Rather than hard code the tag protocol in the
> driver structure, have a callback for the DSA core to call.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Great, this DSA structure finally becomes operation-only.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
