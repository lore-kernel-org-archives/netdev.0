From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Date: Mon, 3 Mar 2008 10:02:10 -0300
Message-ID: <20080303130209.GA4196@ghostprotocols.net>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk> <20080229142334.GL4306@ghostprotocols.net> <20080303073454.GA6937@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53663 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbYCCNCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 08:02:15 -0500
Content-Disposition: inline
In-Reply-To: <20080303073454.GA6937@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 03, 2008 at 07:34:54AM +0000, Gerrit Renker escreveu:
> | > [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
> <snip>
> | I haven't checked, is this over what is now on the test tree or on
> | upstream?
> | 
> The patch applies on top of the test tree (now online again), i.e. it 
> should apply when checking out a separate branch with the test tree in it.
> 
> Are you basically ok with the naming scheme, do you have other
> suggestions or are there additional considerations?

Its ok, everywhere we use hctx or hcrx as the variable name, so its ok
for plain old grep to find it.

- Arnaldo
