From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 08:55:59 -0500
Message-ID: <4880A0EF.9030006@linux-foundation.org>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, davem@davemloft.net,
	johnpol@2ka.mipt.ru
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57553 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756811AbYGRN5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:57:13 -0400
In-Reply-To: <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
> 
> 0x6b is POISON_FREE so 0x6a is one bit corruption.

Typically this means that a refcount at the head of the object was decremented. But the object was already freed.
