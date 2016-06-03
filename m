From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 09/17] net: dsa: Split up creating/destroying of DSA and CPU ports
Date: Fri, 03 Jun 2016 14:37:39 -0400
Message-ID: <87inxq6rv0.fsf@ketchup.mtl.sfl>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch> <1464972256-10408-10-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50269 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbcFCShm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:37:42 -0400
In-Reply-To: <1464972256-10408-10-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Refactor the code to setup a single DSA/CPU port into a function of
> its own, and export it, so it can be used by the new binding.
>
> Similarly, refactor the destroy code into a function.  When destroying
> the ports, don't put the of node. They should be released at the end
> along with the normal ports.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> rfc->v1:
> * Extend commit message with comment about wrong of_node_put()
> * Fix destroy of cpu and dsa ports.
> ---

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
