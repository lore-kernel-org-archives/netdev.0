From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/04]: VLAN vs. packet socket inconsistencies
Date: Tue, 08 Jul 2008 15:38:50 -0700 (PDT)
Message-ID: <20080708.153850.195636789.davem@davemloft.net>
References: <20080708.151233.259338088.davem@davemloft.net>
	<4873EA6C.40408@trash.net>
	<20080708.153510.107686198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752024AbYGHWiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:38:50 -0400
In-Reply-To: <20080708.153510.107686198.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Jul 2008 15:35:10 -0700 (PDT)

> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 09 Jul 2008 00:30:04 +0200
> 
> > That sounds good. Userspace needs to know about the size of
> > the tpacket_hdr before setting the ring parameters so it can
> > size the ring frames appropriately for the largest packet size
> > it wants to receive. This means the offset field in the
> > tpacket_hdr is redundant, so I'll just add a getsockopt
> > option for getting the size. Unless we want to be able to
> > include only a partial tpacket_hdr, but I don't think that
> > would be very useful.
> 
> Ok, in that case using a getsockopt() to query the size sounds great.

BTW, what you might want to do is say that if the user
makes the new getsockopt() size query, he understands
and wants the new style tpacket_hdr layout.
