From: Paul Fulghum <paulkf@microgate.com>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 22 Apr 2008 18:52:57 -0500
Message-ID: <480E7A59.6050802@microgate.com>
References: <480CEB7D.8070702@katalix.com>	<m33apdyajf.fsf@maximus.localdomain>	<480E5CB3.2080003@microgate.com> <20080422.150259.205494753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, jchapman@katalix.com, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-70-250-156-241.dsl.austtx.swbell.net ([70.250.156.241]:34404
	"EHLO gw.microgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbYDVXxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 19:53:38 -0400
In-Reply-To: <20080422.150259.205494753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
 > Users say this to strong-hand developers, it's not something you
 > should ever take very seriously.  And even if Linux may simply not be
 > for them, well that's fine too, and implementing something as obscure
 > as HDLC PPP one way or the other is not going to change that.

Certainly not a big deal for Linux, but more
significant for vendors of HDLC hardware :-)

David Miller wrote:
 > I would have been more than happy if syncppp was retained and fixed
 > properly, instead of being abandoned and duplicated in one fell swoop.

I'd be happy with that also. I was responding to the
suggestion of merging generic HDLC PPP with the pppd implementation.
It's been suggested before, but doing so looks messy.

James Chapman wrote:
 > Paul Fulghum wrote:
 >> Many customers who choose to use generic HDLC PPP are *dead*
 >> set against the added complexity and (user space)
 >> components of using pppd even though it has more features.
 >
 > Are there technical reasons or is the complexity just a lack of
 > familiarity?

 From what I can tell it was an existing investment in scripts,
training, tools, naming conventions, etc. Even when
provided with new tools and scripts that do the same thing (as
far as I could tell) the response was suprisingly vehement against
change.

--
Paul

