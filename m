From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 7/7] dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
Date: Mon, 11 Apr 2016 23:15:26 -0400
Message-ID: <87mvozikkx.fsf@ketchup.mtl.sfl>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch> <1460404209-32083-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54534 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbcDLDPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 23:15:31 -0400
In-Reply-To: <1460404209-32083-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> mv88e6xxx_lookup_name() returns the model name of a switch at a given
> address on an MII bus. Using mii_bus to identify the bus rather than
> the host device is more logical, so change the parameter.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
