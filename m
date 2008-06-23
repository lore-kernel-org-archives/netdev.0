From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Mon, 23 Jun 2008 17:58:26 +0100
Message-ID: <20080623165826.GB8692@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806182246.15433.tomasz@grobelny.oswiecenia.net> <20080619070501.GA7268@gerrit.erg.abdn.ac.uk> <200806202303.37924.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43649 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755292AbYFWQ7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 12:59:09 -0400
Content-Disposition: inline
In-Reply-To: <200806202303.37924.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > We could still encode the parameters in the policy ID, by splitting the
| > bitmask, e.g. the low 24 bits to encode parameters, and the high 8 bits
| > to encode the policies using the same combination of parameters.
| >
| Yes, technically we could do it this way. Encoding accepted parameters in 
| policy ID would provide applications with means to check whether certain 
| parameters are supported. But should we mix two IMO distinct concepts (policy 
| behaviour and accepted parameters) in one bitfield? I'd rather have them 
| separated.
| 
Yes having them separate gives a clearer semantics. But it comes at a price - 
to retrieve the parameters, we need an extra function or lookup table. 

Maybe there is an elegant solution which allows to encode the required
parameters while keeping the semantics clear?

| Keeping policy IDs as they are and using a bitfield for just parameters could 
| be a nice idea. It would certainly  simplify checking which parameters are 
| supported - just a simple & and == would suffice.
| -- 
And it is fast, too.
