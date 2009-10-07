From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Date: Wed, 7 Oct 2009 10:31:59 -0300
Message-ID: <20091007133159.GI16562@ghostprotocols.net>
References: <ccid_coding_convention> <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbZJGNci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 09:32:38 -0400
Content-Disposition: inline
In-Reply-To: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 05, 2009 at 12:53:09PM +0200, Gerrit Renker escreveu:
> Arnaldo, Dave,
> 
> this codifies new naming scheme discussed at netconf. Can you please have a
> look and indicate whether you are ok with the set?
> 
> They are divided into 4 for readability, but can be combined into
> one large patch if agreed.
> 
> It is all just regexp substitutions:
> 
> Patch #1: Introduces the naming scheme on CCID-2:
> 	    s#hc\(tx\|rx\)->ccid2hc\1_#hc\1->\1_#g;
>             s#ccid2hc\(tx\|rx\)_#\1_#g;
> 
> Patch #2: Extends the changes of patch#1 to CCID-3.
> 
> Patch #3: Removes the second, repetitive redundancy in this scheme:
> 	    s#hc\(tx\|rx\)->\1_#hc->\1_#g;
> 
> Patch #4: Extends patch#3 from CCID-2 to CCID-3.

For the 4 patches:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Best Regards,

- Arnaldo
