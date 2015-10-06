From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: HW communication debugging interface - ideas?
Date: Tue, 6 Oct 2015 17:02:34 +0200
Message-ID: <20151006150234.GD32615@lunn.ch>
References: <20151005095633.GE2278@nanopsycho.orion>
 <20151005144941.GC8673@lunn.ch>
 <20151005145542.GJ2278@nanopsycho.orion>
 <20151005145842.GD8673@lunn.ch>
 <20151005151821.GK2278@nanopsycho.orion>
 <56129745.1020805@gmail.com>
 <20151005153554.GM2278@nanopsycho.orion>
 <56129B7D.4040402@gmail.com>
 <20151006081457.GD2165@nanopsycho.orion>
 <5613E091.6000001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36641 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbbJFPCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 11:02:42 -0400
Content-Disposition: inline
In-Reply-To: <5613E091.6000001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sure just throwing out an idea. I suspect whatever interface you have
> will include the vendor-id or some other identifier and a set of
> parsers in user space to pretty print the msg.

If you are going to use wireshark, in this case, all you need to do is
make the stream as being Ethernet frames. The destination and
Ethertype tell you all you need to know to identify the protocol.

	  Andrew
