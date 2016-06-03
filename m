From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/17] net: dsa: Copy the routing table into the switch structure
Date: Fri, 03 Jun 2016 14:27:36 -0400
Message-ID: <87lh2m6sbr.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49809 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbcFCS1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:27:39 -0400
In-Reply-To: <1464972256-10408-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The new binding will not have a chip data structure, it will place the
> routing directly into the switch structure. To enable backwards
> compatibility, copy the routing from the chip data into the switch
> structure.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

The rtable comment has not been updated properly, but that can be fixed
later.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
