From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Fri, 08 May 2009 00:52:51 -0700 (PDT)
Message-ID: <20090508.005251.14244652.davem@davemloft.net>
References: <20090506224134.83F1583420E8@gemini.denx.de>
	<fa686aa40905070709r7478837fnefb094d46f03ae0e@mail.gmail.com>
	<4b73d43f0905071902y3b51d36ct2a04c560b5acdfb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, wd@denx.de, netdev@vger.kernel.org,
	kosmo@semihalf.com, dzu@denx.de
To: jcrigby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756172AbZEHHwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 03:52:55 -0400
In-Reply-To: <4b73d43f0905071902y3b51d36ct2a04c560b5acdfb9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Rigby <jcrigby@gmail.com>
Date: Thu, 7 May 2009 20:02:53 -0600

> Also don't forget that the register map is the same on 512x, mx and
> coldfire platforms but not on the other ppc platforms so if you want
> to one binary to rule them all you will need to have an offest table
> or some such.

I would suggest using ->read_reg() ->write_reg() methods for abstracting
this.  That's how we handle all of the different way ESP scsi chips
have their registers wired up.

I/O register reads take hundreds, if not thousands of CPU cycles so,
relatively speaking, the indirection costs absolutely nothing.
