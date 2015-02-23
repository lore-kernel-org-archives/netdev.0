From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Mon, 23 Feb 2015 14:34:54 +0100
Message-ID: <20150223133454.GB23581@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
 <54EA8E7C.90401@roeck-us.net>
 <20150223031447.GA19267@lunn.ch>
 <54EAA767.6060105@roeck-us.net>
 <20150223042220.GA20063@lunn.ch>
 <54EAAEBC.6080609@roeck-us.net>
 <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47646 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055AbbBWNhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 08:37:53 -0500
Content-Disposition: inline
In-Reply-To: <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> BTW, before I re-submit this patch series, do you think we should
> introduce a fdb_flush() callback that switch drivers are required to
> implement, and invoke it from net/dsa/slave.c upon port join/leave?

Probably a good idea.

We should define exactly what is flushed. Everything? Or only dynamic
entries? The Marvell hardware can also have multicast addresses in its
tables, which can age, or static unicast and multicast entries.

I guess at some point, somebody will start thinking about IGMP
snooping and then we might need separated operations.

	Andrew
