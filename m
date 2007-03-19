From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie root node settings
Date: Mon, 19 Mar 2007 16:30:24 -0700 (PDT)
Message-ID: <20070319.163024.25476350.davem@davemloft.net>
References: <17914.32194.959040.400671@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jens.Laas@data.slu.se, hans.liss@its.uu.se
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030742AbXCSXae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 19:30:34 -0400
In-Reply-To: <17914.32194.959040.400671@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 16 Mar 2007 12:21:38 +0100

> The threshold for root node can be more aggressive set to get
> better tree compression. The new setting mekes the root grow 
> from 16 to 19 bits and substansial improvemnt in Aver depth
> this with the current table of 214393 prefixes 
> 
> But really the dynamic resize should need more investigation 
> both in terms convergence and performance and maybe it should 
> be possible to change...
> 
> Maybe just for the brave to start with or we may have to back 
> this out.

Also applied to net-2.6.22, thanks Robert.
