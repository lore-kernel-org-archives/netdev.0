From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Mon, 23 Feb 2015 17:01:09 +0100
Message-ID: <20150223160109.GB27057@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
 <54EA8E7C.90401@roeck-us.net>
 <20150223031447.GA19267@lunn.ch>
 <54EAA767.6060105@roeck-us.net>
 <20150223042220.GA20063@lunn.ch>
 <54EAAEBC.6080609@roeck-us.net>
 <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
 <20150223133454.GB23581@lunn.ch>
 <54EB37C7.3090209@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47774 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbbBWQEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 11:04:08 -0500
Content-Disposition: inline
In-Reply-To: <54EB37C7.3090209@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I currently use ATU command 110 (flush all non-static entries in a
> particular FID). I see means to flush either all entries or all
> non-static entries, but no means to only flush unicast or multicast
> entries. Does any of the standards distinguish between learned unicast
> and multicast addresses ? Flushing those selectively might be a
> challenge.

You might need to walk the table and flush records individually if you
are only interested in one type.

We should also consider do we need to make these flush operations
atomic with respect to other operations? Do we need to disable
learning, flush, change the port STP status, and then enable learning?

	  Andrew
