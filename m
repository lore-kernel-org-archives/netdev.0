From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 09/37] dccp: Resolve dependencies of features on choice
	of CCID
Date: Wed, 3 Sep 2008 21:59:31 -0300
Message-ID: <20080904005931.GG12639@ghostprotocols.net>
References: <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk> <20080828210713.GP9193@ghostprotocols.net> <20080903045152.GF4105@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41326 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbYIDBFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 21:05:35 -0400
Content-Disposition: inline
In-Reply-To: <20080903045152.GF4105@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Sep 03, 2008 at 06:51:52AM +0200, Gerrit Renker escreveu:
> | > This provides a missing link in the code chain, as several features implicitly
> | > depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
> | > feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).
> | > 
> <snip>
> | 
> | Doesn't this belongs into struct ccid_operations? Why has the core feature
> | negotiation have knowledge of any specific CCID? When people want to
> | merge CCID 4, 5, etc will we need to change net/dccp/feat.c?
> | 
> | I think that this needs thus to go to struct ccid_operations, and then the feature
> | negotiation code can just use use the ccid number to access:
> | 
> | struct ccid_operations *ccids[CCID_MAX]
> | 
> | ccids[ccid_number]->deps

> In principle I agree with you, what I am asking for is to defer this code
> optimisation until later.

Fair enough.

- Arnaldo
