From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Thu, 23 Aug 2007 13:07:30 -0700 (PDT)
Message-ID: <20070823.130730.40743564.davem@davemloft.net>
References: <1187832557.15699.687.camel@faith.austin.ibm.com>
	<20070822.200502.35874480.davem@davemloft.net>
	<1187889310.15699.735.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756302AbXHWUHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 16:07:33 -0400
In-Reply-To: <1187889310.15699.735.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Thu, 23 Aug 2007 12:15:10 -0500

> For example, when auditing the addition of a policy, either
> xfrm_user_audit_policy_add(xp, result, skb) or
> pfkey_audit_policy_add(xp, result) will get called. 
> I need two because xfrm_user gets loginuid/secid from netlink/skb
> and pfkey gets it from audit_get_loginuid(). 
> Each will setup and format audit buffer according
> to what they want.
> 
> Also, for deleting, there will be pfkey_audit_policy_delete(xp, result)
> and xfrm_user_audit_policy_delete(xp, result, skb).

This sounds great.

How cheap is the "auditing enabled" test?  Perhaps it can
be even inlined into the xfrm audit hooks.
