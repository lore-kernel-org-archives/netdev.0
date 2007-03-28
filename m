From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] NET : secure sequence number functions can use nsec
 resolution instead of usec
Date: Wed, 28 Mar 2007 12:31:56 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703281231200.3715@d.namei>
References: <20070328174322.5d806dd0.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:53791 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725AbXC1Qb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 12:31:59 -0400
In-Reply-To: <20070328174322.5d806dd0.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Mar 2007, Eric Dumazet wrote:

> Hello David
> 
> We could use the nanosec resolution for various functions defined in drivers/char/random.c
> (secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number())
> 
> I am not sure if it's a netdev related patch or core kernel, so I have CC Andrew.
> 
> Thank you
> 
> [PATCH] NET : random functions can use nsec resolution instead of usec
> 
> In order to get more randomness for secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number() functions, we can use the high resolution time services, providing nanosec resolution.
> 
> I've also done two kmalloc()/kzalloc() conversions.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks good to me.

Acked-by: James Morris <jmorris@namei.org>



- James
-- 
James Morris
<jmorris@namei.org>
