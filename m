From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] twcal_jiffie should be unsigned long, not int
Date: Mon, 05 Mar 2007 13:33:31 -0800 (PST)
Message-ID: <20070305.133331.45179714.davem@davemloft.net>
References: <45EBFD13.1060106@symas.com>
	<200703051528.02564.dada1@cosmosbay.com>
	<200703051609.21133.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@mandriva.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933626AbXCEVdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 16:33:35 -0500
In-Reply-To: <200703051609.21133.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 5 Mar 2007 16:09:21 +0100

> While browsing include/net/inet_timewait_sock.h, I found this buggy definition 
> of twcal_jiffie.
> 
> int         twcal_jiffie;
> 
> I wonder how inet_twdr_twcal_tick() can really works on x86_64
> 
> This seems quite an old bug, it was there before introduction of 
> inet_timewait_death_row made by Arnaldo Carvalho de Melo.
> 
> [PATCH] twcal_jiffie should be unsigned long, not int
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Grrr, good catch Eric.  I'll push this fix to -stable too.

Thanks a lot.
