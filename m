From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 2 Jun 2015 15:42:52 +0200
Message-ID: <20150602134252.GT22739@lunn.ch>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <556D522E.90607@roeck-us.net>
 <CAE4R7bChwW1awn8V6k7bF13v15_kPF0ui3NvyV2WkqN0XuTUqw@mail.gmail.com>
 <556DB283.8080300@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel@savoirfairelinux.com, Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50011 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbbFBNsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 09:48:19 -0400
Content-Disposition: inline
In-Reply-To: <556DB283.8080300@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also, we already have cases where the switch is connected to the CPU with
> more than one Ethernet port. It is easy to imagine that the user of such
> a system might want to configure two bridge groups.
 
Hi Guenter

I think that is orthogonal.  Having multiple CPU ports should really
only be seen as increased throughput with load sharing. It makes no
different to the basic user use cases. They can all be done with a
single CPU port, but with less bandwidth.

       Andrew
