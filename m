From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 03:02:19 +0200
Message-ID: <200608090302.19634.ak@suse.de>
References: <200608080711.06788.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net> <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:51106 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1030386AbWHIBD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 21:03:28 -0400
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> But there's alot of state to update (more or less
> atomically, too) 

Why does it need to be atomic? It might be enough
to just check a flag and poll for it in the readers and then redo the 
lookup.

> in the TCP hashes. Looks tricky to 
> do that without hurting performance, especially since
> you'll probably want to resize the tables when you've
> discovered they're full and busy....

There will be some hickup, but as long as the downtime
is limited it shouldn't be too bad.

-Andi

 
