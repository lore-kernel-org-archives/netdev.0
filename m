From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 05/11] net: dsa: mv88e6xxx: Add comment about family a device belongs to
Date: Mon, 14 Nov 2016 13:08:13 +1100
Message-ID: <8737iubype.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40418 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755155AbcKNCIX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 21:08:23 -0500
In-Reply-To: <1478832823-31471-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Knowing the family of device belongs to helps with picking the ops
> implementation which is appropriate to the device. So add a comment to
> each structure of ops.

This commit is not necessary. mv88e6xxx_ops structure must be per-chip,
and the family information is already described in patch 03/11.

Thanks,

        Vivien
