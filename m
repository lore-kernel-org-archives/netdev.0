From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: v2 [PATCH 1/5] dccp: Basic data structure for feature
	negotiation
Date: Wed, 24 Sep 2008 10:59:54 -0300
Message-ID: <20080924135954.GJ9588@ghostprotocols.net>
References: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk> <20080922142105.GB16625@ghostprotocols.net> <20080922154554.GA3521@gerrit.erg.abdn.ac.uk> <20080922.202056.218746153.davem@davemloft.net> <20080924051823.GB4944@gerrit.erg.abdn.ac.uk> <20080924052305.GC4944@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41385 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbYIXOAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 10:00:14 -0400
Content-Disposition: inline
In-Reply-To: <20080924052305.GC4944@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 24, 2008 at 07:23:05AM +0200, Gerrit Renker escreveu:
> This is the second/other revised patch for this set [v2 of 1/5].
> 
> Changes relative to v1: copied Arnaldos suggested layout and updated the
> struct documentation accordingly. Compile-tested the result.
> 
> >>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> dccp: Basic data structure for feature negotiation
> 
> This patch prepares for the new and extended feature-negotiation routines.
> 
> The following feature-negotiation data structures are provided:
> 	* a container for the various (SP or NN) values,
> 	* symbolic state names to track feature states,
> 	* an entry struct which holds all current information together,
> 	* elementary functions to fill in and process these structures.
> 
> Entry structs are arranged as FIFO for the following reason: RFC 4340 specifies
> that if multiple options of the same type are present, they are processed in the
> order of their appearance in the packet; which means that this order needs to be
> preserved in the local data structure (the later insertion code also respects
> this order).
> 
> The struct list_head has been chosen for the following reasons: the most 
> frequent operations are
>  * add new entry at tail (when receiving Change or setting socket options);
>  * delete entry (when Confirm has been received);
>  * deep copy of entire list (cloning from listening socket onto request socket).
> 
> The NN value has been set to 64 bit, which is a currently sufficient upper limit
> (Sequence Window feature has 48 bit).
> 
> Thanks to Arnaldo who streamlined the field layout of the entry struct.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
