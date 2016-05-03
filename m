From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 3/9] netfilter: conntrack: don't attempt to
 iterate over empty table
Date: Wed, 4 May 2016 00:27:42 +0200
Message-ID: <20160503222742.GA1196@salvia>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-4-git-send-email-fw@strlen.de>
 <20160503170357.GA21641@salvia>
 <20160503171744.GG2395@breakpoint.cc>
 <20160503174144.GA3782@salvia>
 <20160503175559.GJ2395@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47652 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756688AbcECW1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:27:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1980DE5A5D
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 00:27:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F399A358D
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 00:27:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 023B6D1D85
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 00:27:44 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20160503175559.GJ2395@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2016 at 07:55:59PM +0200, Florian Westphal wrote:
> > Otherwise, every time we'll go container destruction path, we'll hit
> > slow path, ie.  scanning the full table.
> 
> Yes, but I see no other choice.

Fair enough, will place this in nf-next, thanks.
