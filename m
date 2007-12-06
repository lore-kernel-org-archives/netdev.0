From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 6 Dec 2007 12:35:05 +0100
Message-ID: <200712061235.06025.stefan@loplof.de>
References: <200712060949.02524.stefan@loplof.de> <200712061156.48810.stefan@loplof.de> <20071206.031302.201608796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753015AbXLFLeR@vger.kernel.org>
In-Reply-To: <20071206.031302.201608796.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 6. Dezember 2007 12:13 schrieb David Miller:

> And that's why this is a grey area.  Why is waiting for memory
> allocation on a O_NONBLOCK socket OK but waiting for IPSEC route
> resolution is not?

Because you just will put enough RAM modules into you server when setting up a 
scalable system. Local resource, managable by the admin. What you cannot 
control in many cases is the network connection to the remote node. Simon 
Arlott has been talking about an 8 hour network outage.

Stefan
