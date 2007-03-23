From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 23:22:20 -0700 (PDT)
Message-ID: <20070322.232220.71113011.davem@davemloft.net>
References: <1174598630.3085.285.camel@faith.austin.ibm.com>
	<Line.LNX.4.64.0703221943110.24461@d.namei>
	<1174628387.10788.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, latten@austin.ibm.com, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@TrustedCS.com
To: eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41365
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753116AbXCWGWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 02:22:20 -0400
In-Reply-To: <1174628387.10788.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@parisplace.org>
Date: Fri, 23 Mar 2007 01:39:47 -0400

> It seems reasonable to me that the check for every policy (which is
> between current->security->sid and xp->security->ctx_sid) makes sense.
> There doesn't appear to me right offhand to be anything intrinsic in the
> code which says that a flush request must flush everything or nothing.

The "intrinsic" part comes from the heritage of routing daemons and
what they expect from flush operations, these assumption live in the
ipsec daemons as well.

A daemon, routing or ipsec, is flushing the tables in order to create
an entirely "clean slate", and they very much expect the policy and
state tables to be %100 empty after the operation.
