From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat II
Date: Tue, 8 Jan 2008 03:08:38 +0100
Message-ID: <20080108020838.GD16156@one.firstfloor.org>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <20080105.231658.168081302.davem@davemloft.net> <p73sl19qi6o.fsf@bingen.suse.de> <20080107.175458.127194310.davem@davemloft.net> <20080108020529.GC16156@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, acme@redhat.com,
	paul.moore@hp.com, latten@us.ibm.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50721 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbYAHCGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 21:06:15 -0500
Content-Disposition: inline
In-Reply-To: <20080108020529.GC16156@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> % awk '  { line++ } ; /^{/ { start = line } ; /^}/ { n++; r += line-start-2; } ; END { print r/n }' < include/net/tcp.h 
> 9.48889
> 
> The average function length is 9 lines.

Actually 8 -- the awk hack had a off by one. Still too long.

-Andi
