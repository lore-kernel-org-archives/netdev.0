From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : force a cache line split in hh_cache in SMP
Date: Fri, 08 Dec 2006 00:08:58 -0800 (PST)
Message-ID: <20061208.000858.03110623.davem@davemloft.net>
References: <45789D94.3050509@cosmosbay.com>
	<20061207.150718.41636608.davem@davemloft.net>
	<45791D08.7070804@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425146AbWLHIIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 03:08:44 -0500
To: dada1@cosmosbay.com
In-Reply-To: <45791D08.7070804@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 Dec 2006 09:06:32 +0100

> hh_lock was converted from rwlock to seqlock by Stephen.
> 
> To have a 100% benefit of this change, I suggest to place read mostly fields 
> of hh_cache in a separate cache line, because hh_refcnt may be changed quite 
> frequently on some busy machines.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
