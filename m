From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 01/17] net: dsa: slave: chip data is optional, don't dereference NULL
Date: Fri, 03 Jun 2016 14:09:07 -0400
Message-ID: <8737ou87r0.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48820 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbcFCSJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:09:11 -0400
In-Reply-To: <1464972256-10408-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The new binding does not make use of dsa_chip_data, a.k.a cd.  When
> retrieving the size of the EEPROM attached to a switch, don't assume
> there is a cd attached to the switch structure.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
