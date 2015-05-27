From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Wed, 27 May 2015 23:05:23 +0200
Message-ID: <20150527210523.GE31127@lunn.ch>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com>
 <20150526225142.GB26454@roeck-us.net>
 <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com>
 <556630EA.7060707@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Chris Healy <cphealy@gmail.com>,
	=?iso-8859-1?Q?J=E9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41958 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbbE0VKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 17:10:39 -0400
Content-Disposition: inline
In-Reply-To: <556630EA.7060707@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Do you have lock debugging enabled in your code ? I am getting a recursive
> lock warning due to a recursive call to dev_mc_sync(). I think we may have
> to implement lock nesting for dsa, similar to how it id done for vlan
> support, but I have not been able to figure out how exactly it works yet.

I might be able to help, since i solve two similar problems already in
DSA, one for MDIO bus, and a second one for transmit buffers.

     Andrew
