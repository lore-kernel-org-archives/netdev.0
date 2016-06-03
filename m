From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 03/17] net: dsa: slave: Remove MDIO address from switch MDIO bus name
Date: Fri, 03 Jun 2016 14:10:57 -0400
Message-ID: <87zir26t3i.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48910 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbcFCSK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:10:59 -0400
In-Reply-To: <1464972256-10408-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The DSA layer should no longer assume the switch is connected to an
> MDIO bus. As a result, we cannot use the address on the MDIO bus when
> forming the name of the switches internal MDIO bus for its builtin and
> possibly external PHYs. The switch index is sufficient to make the
> name unique, so drop the MDIO address.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
