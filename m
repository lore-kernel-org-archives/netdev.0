From: Thomas Graf <tgraf@suug.ch>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 00:54:35 +0200
Message-ID: <20080523225435.GT20815@postel.suug.ch>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr> <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com> <1211569604.11907.37.camel@perihelion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37805 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630AbYEWWyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 18:54:15 -0400
Content-Disposition: inline
In-Reply-To: <1211569604.11907.37.camel@perihelion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jon Masters <jonathan@jonmasters.org> 2008-05-23 15:06
> My intention is to also allow for:
> 
> ifcfg-slot_<whatever>
> 
> Where the configuration is based entirely upon what vendor <XYZ> says is
> the first, second, or third card. Then, those who want to use the older
> names can continue to do so, but those who prefer to base their
> configuration upon the order the vendor states, can do so.

I'd propose to extend the netlink configuration interface, f.e. introduce a
new netlink attribtue IFLA_SLOT which can be provided to select the device
to be changed based on the slot number instead of the name/ifindex. That
would also make it trivial to write a small app using RTM_GETLINK to
translate a slot number to the corresponding interface name.
