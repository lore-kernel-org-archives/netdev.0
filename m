From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices (v3)
Date: Wed, 10 Feb 2010 12:31:02 -0800
Message-ID: <87d40chlyx.fsf@caffeine.danplanet.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
	<87ljf1gemh.fsf@caffeine.danplanet.com>
	<20100210192019.GA18879@us.ibm.com>
	<87hbpohor5.fsf@caffeine.danplanet.com>
	<20100210202509.GA23301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:52911 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755493Ab0BJUbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 15:31:05 -0500
In-Reply-To: <20100210202509.GA23301@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 10 Feb 2010 14\:25\:09 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> I think that's be better.  Right now if we checkpoint a container
SH> with macvlan restart will be bogus, right?  We're trying to avoid
SH> any cases where we can't tell, at checkpoint, that restart won't
SH> be right.

Depends on your definition of bogus, and the situation, but okay.

SH> What I was asking is should do_veth_message() be in drivers/net/veth.c?

Well, we could add another ndo_* function to the net device, I guess,
but I'd be afraid we'd hit some cases where that wasn't sufficient.
Maybe it would be best to generalize that bit after I've added macvlan
(,etc) support so we have a good idea of what else would be needed?

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
