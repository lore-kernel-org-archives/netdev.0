From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/17] net: dsa: tag_{e}dsa.c: Remove dependency on platform data
Date: Fri, 03 Jun 2016 14:12:45 -0400
Message-ID: <87wpm66t0i.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49078 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbcFCSMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:12:48 -0400
In-Reply-To: <1464972256-10408-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The platform data nr_chips is used when validating a received packet,
> to ensure it comes from a know switch chip. The number of possible
> switches is limited to DSA_MAX_SWITCHES, so use this as the first
> validation step. The new binding allows holes in the dst->ds[] array,
> so also ensure ensure there is a valid dsa_switch for this packet.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
