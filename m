From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: v2 [PATCH 2/5] dccp: Implement lookup table for
	feature-negotiation information
Date: Wed, 24 Sep 2008 11:01:21 -0300
Message-ID: <20080924140121.GK9588@ghostprotocols.net>
References: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk> <20080922142105.GB16625@ghostprotocols.net> <20080922154554.GA3521@gerrit.erg.abdn.ac.uk> <20080922.202056.218746153.davem@davemloft.net> <20080924051823.GB4944@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41422 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478AbYIXOBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 10:01:41 -0400
Content-Disposition: inline
In-Reply-To: <20080924051823.GB4944@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 24, 2008 at 07:18:23AM +0200, Gerrit Renker escreveu:
> This is the first revised patch, the second follows subsequently.
> 
> Changes relative to v1: 
> migrated function `dccp_default_value' moved to where it is first used 
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: Implement lookup table for feature-negotiation information
> 
> A lookup table for feature-negotiation information, extracted from RFC 4340/42,
> is provided by this patch. All currently known features can be found in this 
> table, along with their feature location, their default value, and type.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Lets make progress, in the future lets try and remove hardcoded specific CCID
tests.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
