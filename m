From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Fri, 23 Mar 2007 14:50:31 -0400
Message-ID: <1174675831.10788.79.camel@localhost.localdomain>
References: <Line.LNX.4.64.0703221943110.24461@d.namei>
	 <1174628387.10788.53.camel@localhost.localdomain>
	 <Line.LNX.4.64.0703231441390.30602@d.namei>
	 <20070323.114724.74563713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, latten@austin.ibm.com, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@TrustedCS.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbXCWSyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 14:54:15 -0400
In-Reply-To: <20070323.114724.74563713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-23 at 11:47 -0700, David Miller wrote:
> From: James Morris <jmorris@namei.org>
> Date: Fri, 23 Mar 2007 14:46:48 -0400 (EDT)
> 
> > A 'flush' has a semantic implication that all entries will be removed, and 
> > it should be atomic and either succeed or fail at that granularity.
> 
> Correct.

Fair enough, does it matter that we have no way to report failure back
to users who can no longer assume success?

-Eric

