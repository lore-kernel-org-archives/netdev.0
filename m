From: Guy Harris <guy@alum.mit.edu>
Subject: Re: HW communication debugging interface - ideas?
Date: Sun, 1 Nov 2015 09:58:14 -0800
Message-ID: <8F75544D-55A9-4DDD-96DB-F012DEF41BD5@alum.mit.edu>
References: <20151005095633.GE2278@nanopsycho.orion> <20151005144941.GC8673@lunn.ch> <20151005145542.GJ2278@nanopsycho.orion> <20151005145842.GD8673@lunn.ch> <20151005151821.GK2278@nanopsycho.orion> <56129745.1020805@gmail.com> <20151005153554.GM2278@nanopsycho.orion> <56129B7D.4040402@gmail.com> <20151006081457.GD2165@nanopsycho.orion> <5613E091.6000001@gmail.com> <20151006150234.GD32615@lunn.ch>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:50459 "EHLO d.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbbKASKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 13:10:16 -0500
In-Reply-To: <20151006150234.GD32615@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 6, 2015, at 8:02 AM, Andrew Lunn <andrew@lunn.ch> wrote:

>> Sure just throwing out an idea. I suspect whatever interface you have
>> will include the vendor-id or some other identifier and a set of
>> parsers in user space to pretty print the msg.
> 
> If you are going to use wireshark, in this case, all you need to do is
> make the stream as being Ethernet frames. The destination and
> Ethertype tell you all you need to know to identify the protocol.

You will, of course, have registered that Ethertype with the IEEE, to ensure nobody else registers it for use with a different protocol.