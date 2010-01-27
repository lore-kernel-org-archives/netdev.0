From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: Network QoS support in applications
Date: Wed, 27 Jan 2010 09:11:52 +0200
Message-ID: <87zl40konb.fsf@purkki.valot.fi>
References: <877hr5nkx0.fsf@purkki.valot.fi>
	<20100126.041610.226004766.davem@davemloft.net>
	<87wrz5m3cd.fsf@purkki.valot.fi>
	<20100126.050645.184040277.davem@davemloft.net>
	<87my01m0zm.fsf@purkki.valot.fi> <4B5EF5DF.2070005@lemonia.org>
	<87iqaplz5a.fsf@purkki.valot.fi>
	<20100126215401.GA25095@laped.iglesias.mooo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dunc <dunc@lemonia.org>, David Miller <davem@davemloft.net>,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:56596 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0A0HL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 02:11:56 -0500
In-Reply-To: <20100126215401.GA25095@laped.iglesias.mooo.com> (Edgar E. Iglesias's message of "Tue\, 26 Jan 2010 22\:54\:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Edgar E. Iglesias" <edgar.iglesias@gmail.com> writes:

> IMO what apps should be doing is setting the DSCP to a user configurable
> value (config file or cmd line switch etc). This way people can choose DSCP
> to whatever makes sense in their particular network. The default value
> is of less interest.

I have to disagree here. Most of the people are not that interested
configuring their applications, they just want to use them. I see that
having this configurable would be just an excuse for not having a good
default value.

Also it just doesn't scale if every user has to start configuring all
network applications they use. IMHO this all should work "Out of Box".

> WRT L3 vs L2, I think apps should normally be tagging by setting the DSCP
> field. The kernel should provide configurable mappings between DSCP and
> what ever L2 QoS that is available on the egress interface. As the packet
> jumps and gets routed, the DSCP value gets remapped two every links
> particular L2 "QoS" that matches the DSCP. After all, apps shouldn't need to
> know their hooked up to a 802.11, wired ethernet or what ever is on the
> route to the peer...

With this one I fully agree. I think this is the way we should do
this.

> AFAIK, Linux already makes all of this perfectly possible.

Yes, it's possible but not widely used because people don't know about
this. We need to provide documentation and then push applications to
use this.

> My 2 cents..

Thank you very much, much appreciated.

-- 
Kalle Valo
