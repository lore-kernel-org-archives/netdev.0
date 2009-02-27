From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 23:28:02 +0100
Message-ID: <20090227222802.GZ17040@xi.wantstofly.org>
References: <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>, netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <jdb@comx.dk>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:56428 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434AbZB0W2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 17:28:07 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 10:12:52PM +0100, Jesper Dangaard Brouer wrote:

> >Perhaps we should take this off-list..
> 
> I'm still interrested... please Cc. me at jdb@comx.dk.

The main conclusion so far is that this write (net/dsa/mv88e6131.c):

	/*
	 * MAC Forcing register: don't force link, speed, duplex
	 * or flow control state to any particular values.
	 */
	REG_WRITE(addr, 0x01, 0x0003);

isn't correct on ports that can either be CPU ports or external ports.
Forcing the link up on the CPU port helps somewhat, but things aren't
100% working yet.
