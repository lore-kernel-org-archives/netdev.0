From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 17:19:36 -0700 (PDT)
Message-ID: <20090429.171936.91197184.davem@davemloft.net>
References: <1240945659.8819.9.camel@Maple>
	<1241050188.18295.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbZD3ATm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:19:42 -0400
In-Reply-To: <1241050188.18295.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@verizon.net>
Date: Wed, 29 Apr 2009 17:09:48 -0700

> After going back to my original NAPI changes, email exchanges today with
> Francois and John, and looking through all the architecture
> implementation of mmiowb and locking; I agree that this mmiowb is
> unnecessary since a lock is always released which has all the memory
> barriers needed.  I no longer have access to all the equipment I had
> available at IBM, but it was tested a extensively on Intel and Power
> platforms without the mmiowb.
> 
> Acked-by:  Don Fry <pcnet32@verizon.net>

Looks good to me too, I'll apply this to net-next-2.6

Thanks
