From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4 for Source VIPA support, kernel BK Head
Date: Sun, 5 Sep 2004 20:22:15 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040905202215.5ed8bf5f.davem@davemloft.net>
References: <200409011441.10154.elueck@de.ibm.com>
	<Pine.LNX.4.61.0409011852380.2441@fogarty.jakma.org>
	<20040905230219.GA24688@srv01.cluenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paul@clubi.ie, lkml@einar-lueck.de, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S264531AbUIFDYa@vger.kernel.org>
To: Daniel Roesen <dr@cluenet.de>
In-Reply-To: <20040905230219.GA24688@srv01.cluenet.de>
List-Id: netdev.vger.kernel.org

On Mon, 6 Sep 2004 01:02:19 +0200
Daniel Roesen <dr@cluenet.de> wrote:

> On Thu, Sep 02, 2004 at 05:22:01PM +0100, Paul Jakma wrote:
> > ip route add default via <gateway> src <virtual ip>
> 
> Sitenote: unfortunately, "src <...>" doesn't work for IPv6 routes, at
> least in 2.4 -- can someone confirm this problem to still exist in
> current 2.6?

That's right, no routing by source in ipv6 yet, the folks
working with the USAGI guys on MIPV6 support will add the
feature.
