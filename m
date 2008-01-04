From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] LSM: Add inet_sys_snd_skb() LSM hook
Date: Fri, 04 Jan 2008 13:09:02 -0800 (PST)
Message-ID: <20080104.130902.217217806.davem@davemloft.net>
References: <20080103172539.14445.1668.stgit@flek.americas.hpqcorp.net>
	<20080103.204549.204229388.davem@davemloft.net>
	<200801040938.27515.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753698AbYADVJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 16:09:02 -0500
In-Reply-To: <200801040938.27515.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 4 Jan 2008 09:38:27 -0500

> Unfortunately, it's not quite that easy at present.  The only field we 
> have in the skb where we could possibly set a flag is the secmark field 
> which is already taken.

Herbert Xu added a "peeked" field in net-2.6.25 that is only used on
input while processing socket receive queues.  You could use it on
output.
