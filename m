From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Modify return value for the .ndo_set_mac_address
Date: Fri, 04 Dec 2009 13:30:18 -0800 (PST)
Message-ID: <20091204.133018.10228592.davem@davemloft.net>
References: <20091204114721.GA5505@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757310AbZLDVaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 16:30:11 -0500
In-Reply-To: <20091204114721.GA5505@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Fri, 4 Dec 2009 14:47:22 +0300

> Return -EADDRNOTAVAIL insted of -EINVAL in .ndo_set_mac_address.
> 
> Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

Why?

The address is "invalid" so we return "invalid" error.

What's the problem?

And whether there is a good reason or not, your commit message did not
describe that reason so needs to be updated.
