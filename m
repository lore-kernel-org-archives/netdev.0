From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Mon, 02 Mar 2009 08:14:39 -0700
Message-ID: <49ABF7DF.8060302@mlbassoc.com>
References: <20090227145746.GD17040@xi.wantstofly.org>	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>	 <20090227222802.GZ17040@xi.wantstofly.org>	 <1235991382.30736.62.camel@localhost.localdomain> <1235991937.30736.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:4943 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbZCBPPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 10:15:04 -0500
In-Reply-To: <1235991937.30736.65.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Mon, 2009-03-02 at 11:56 +0100, Jesper Dangaard Brouer wrote:
> 
>> You should write 0x003E ... see attached patch
> 
> Ups, I see (from the thread) that you have already done/tried this...
> 

Yes, although I think it will need some work in the future
(I've set it to 1000Mb connection, you said you used 100Mb, etc)

Question: I'm testing this by trying a ping out of my box.
Linux replies by sending an ARP packet out, and the destination
replies with an ARP packet in.  I can see from the ethtool stats
that the reply packets get into lan1.1 (the physical port I'm
using), but I don't see them get moved through the CPU port.
My understanding is that this should work via the VLAN map?
I checked that setup and it looks OK.

Any ideas where this might be going wrong?

Thanks

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
