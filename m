From: David Miller <davem@davemloft.net>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 05:06:45 -0800 (PST)
Message-ID: <20100126.050645.184040277.davem@davemloft.net>
References: <877hr5nkx0.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
	<87wrz5m3cd.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: kalle.valo@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753327Ab0AZNGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 08:06:33 -0500
In-Reply-To: <87wrz5m3cd.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kalle.valo@iki.fi>
Date: Tue, 26 Jan 2010 14:56:50 +0200

> In my opinion we already now need a universal solution for the user
> space applications to classify their streams. Having a local solution
> doesn't get us far, people don't want to configure their laptops or
> phones, they just want to use them :)

And similarly your organization's administartion doesn't want to
prioritize bittorrent traffic a specific fixed way just because your
application sets some bits in the TOS field of it's packets.

Prioritization policies have no meaning outside of your local realm,
and that's just a fact of life.

So what typically happens is that applications do nothing.

And machines on the ingress to a network realm change the TOS based
field upon classification decisions made by parsing the packet by the
router/firewall/whatever.

The packet gets QoS treatment within the realm, but completely
determined by local policy within that realm.

And then on egress from the realm the TOS field has absolutely
no meaning at all to the next network segment.
