From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Fri, 19 Jun 2015 17:05:33 +0200
Message-ID: <20150619150533.GH3557@lunn.ch>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch>
 <1434129537-15252-3-git-send-email-andrew@lunn.ch>
 <557F0CD5.4070705@gmail.com>
 <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com>
 <20150618011159.GA22072@lunn.ch>
 <2144581324.52952.1434726314482.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59187 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398AbbFSPLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 11:11:31 -0400
Content-Disposition: inline
In-Reply-To: <2144581324.52952.1434726314482.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes I do have debug too, but via sysfs (with eventually write access) for:
> GLOBAL1, GLOBAL2, cpu port registers, SerDes registers, PVIDs, and VTU.
> Not really standard though.

We should really get an implementation into mainline. There is no
point us all implementing our own.

You say your code is not really standard. Do you think it would get
rejected if it was submitted? The rules for debugfs are much more
relaxed, so what i have should be acceptable.

	 Andrew
