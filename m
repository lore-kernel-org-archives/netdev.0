From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 06/17] net: dsa: Move port device node into port structure
Date: Fri, 03 Jun 2016 14:19:03 -0400
Message-ID: <87r3ce6sq0.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49380 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbcFCSTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:19:07 -0400
In-Reply-To: <1464972256-10408-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Move the port device node structure into the port structure, from the
> chip data. This information is needed in the next step of implementing
> the new binding.
>
> The chip data structure is used while parsing the whole old binding,
> before the individual switch structures exist. With the new bindings,
> this is reversed, the switches exist first, and the interconnections
> between the switches is derived from the individual switch
> bindings. Thus this chip data structure becomes unneeded.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
