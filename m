From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : secure sequence number functions can use nsec
 resolution instead of usec
Date: Wed, 28 Mar 2007 14:22:54 -0700 (PDT)
Message-ID: <20070328.142254.94073845.davem@davemloft.net>
References: <20070328174322.5d806dd0.dada1@cosmosbay.com>
	<Line.LNX.4.64.0703281231200.3715@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, andi@firstfloor.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbXC1VWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 17:22:54 -0400
In-Reply-To: <Line.LNX.4.64.0703281231200.3715@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Wed, 28 Mar 2007 12:31:56 -0400 (EDT)

> On Wed, 28 Mar 2007, Eric Dumazet wrote:
> 
> > Hello David
> > 
> > We could use the nanosec resolution for various functions defined in drivers/char/random.c
> > (secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number())
> > 
> > I am not sure if it's a netdev related patch or core kernel, so I have CC Andrew.
> > 
> > Thank you
> > 
> > [PATCH] NET : random functions can use nsec resolution instead of usec
> > 
> > In order to get more randomness for secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number() functions, we can use the high resolution time services, providing nanosec resolution.
> > 
> > I've also done two kmalloc()/kzalloc() conversions.
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> Looks good to me.
> 
> Acked-by: James Morris <jmorris@namei.org>

To me too, patch applied, thanks everyone.
