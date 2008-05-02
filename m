From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Fri, 2 May 2008 21:56:54 +0100
Message-ID: <20080502205654.GB5116@gerrit.erg.abdn.ac.uk>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804282303.40673.tomasz@grobelny.oswiecenia.net> <20080430075332.GA4277@gerrit.erg.abdn.ac.uk> <200805022239.58699.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:44422 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762092AbYEBU47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 16:56:59 -0400
Content-Disposition: inline
In-Reply-To: <200805022239.58699.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | c) allow qpolicy to use each cmsg header as different parameter. So that
| > (...)
| > I think (c) is best, here is what I'd support.
| > (...)
| Seems we are getting closer in our views, see the just sent patch.
| 
That would be good - what I would like to do is to replace the 12 or so
patches in git://eden-feed.erg.abdn.ac.uk/dccp_exp [qpolicy subtree]
with a single patch and then put it into the test tree.

Will answer regarding the other patch separately and then resubmit the 
combined patch to the list - if you are ok with it, you can add your
signed-off or point out where you disagree. It remains your patch.

What I'd still like to do is some testing on different architectures.

| > I.e. to answer the question, I think it is best to implement "timeout"
| > first, solve the problems it brings up; when that is done,
| > "priority+timeout" will be easy to do - it could be constructed just out of
| > the existing functions defined for "priority" and "timeout".
| >
| > In that manner, other policies can be modularly constructed - for instance
| > by combining "timeout" with a different form of the "priority" policy.
| >
| I'm not entirely sure if such modular constructions would be possible. I 
| prefer to think of "timeout policy" and "prio policy" as a special cases 
| of "timeout+prio policy" with respectively DCCP_SCM_PRIORITY and 
| DCCP_SCM_TIMEOUT not supplied (and thus set to their default values: 0 and 
| INFINITY).
| -- 
It depends on the way one looks at it. Your view is top-down, mine is
bottom-up, both can work. Agree with the parameters.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

