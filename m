From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: HW communication debugging interface - ideas?
Date: Mon, 5 Oct 2015 16:49:41 +0200
Message-ID: <20151005144941.GC8673@lunn.ch>
References: <20150930135141.GF2098@nanopsycho.orion>
 <9B0331B6EBBD0E4684FBFAEDA55776F91944E43E@HASMSX110.ger.corp.intel.com>
 <20151005095633.GE2278@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35784 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030AbbJEOts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 10:49:48 -0400
Content-Disposition: inline
In-Reply-To: <20151005095633.GE2278@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Are you referring here to messages of the EMAD protocol ?

I know nothing about this protocol.....

Does it at least use standard Ethernet framing? Source and Destination
header and an EtherType which mean EMAD?

Marvell has a way to access registers of their switches using Ethernet
Frames, and they are valid frames with a specific EtherType. Linux
does not use them, but if it did, i would of thought passing them
along using the normal pcap interface would be trivial.

      Andrew
