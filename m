From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHES 0/5]: Add hashinfo member to struct proto and get
 net/ structs back on a diet
Date: Sun, 03 Feb 2008 04:09:43 -0800 (PST)
Message-ID: <20080203.040943.193695583.davem@davemloft.net>
References: <47a39bf3.1087460a.06ae.ffffd95f@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45470
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752809AbYBCMJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 07:09:18 -0500
In-Reply-To: <47a39bf3.1087460a.06ae.ffffd95f@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: acme@ghostprotocols.net
Date: Fri,  1 Feb 2008 20:23:31 -0200

> Hi David,
> 
> 	Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25
> 
> 	There are many more structs that have holes, they seem to crop up, even
> on DCCP! People should use some paholing 8-)
> 
> 	I'll prepare another round after carnival, and also will look at using
> sparse and/or Uli's libdisasm and/or DeHydra to find struct member accesses in
> functions to correlate that with struct layout when doing automatic struct
> member reorgs, so as not to step into Eric's fast path 8-P

I've pulled these all in as patches, thanks for following
up on this work!
