From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Fri, 23 Mar 2007 11:47:24 -0700 (PDT)
Message-ID: <20070323.114724.74563713.davem@davemloft.net>
References: <Line.LNX.4.64.0703221943110.24461@d.namei>
	<1174628387.10788.53.camel@localhost.localdomain>
	<Line.LNX.4.64.0703231441390.30602@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, latten@austin.ibm.com,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	vyekkirala@TrustedCS.com
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753309AbXCWSrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:47:25 -0400
In-Reply-To: <Line.LNX.4.64.0703231441390.30602@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Fri, 23 Mar 2007 14:46:48 -0400 (EDT)

> A 'flush' has a semantic implication that all entries will be removed, and 
> it should be atomic and either succeed or fail at that granularity.

Correct.
