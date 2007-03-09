From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 8 Mar 2007 23:16:58 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026E982F@orsmsx414.amr.corp.intel.com>
References: <20070308.231142.74749203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13940 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993033AbXCIHRA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 02:17:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070308.231142.74749203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is not a problem.
> 
> Since the ->enqueue function stores references to the SKBs, 
> any change of the dev->qdisc has to flush those references 
> somehow, and it is at that point that you can fixup the skb 
> queue mappings.
> 
> This happens via invoking the qdisc->ops->reset() method.
> 

Thanks Dave.  It seems expensive to change all the skb's if this type of
event occurs, but I suppose it is a corner case and can be tolerated.
Please let me make this change and I'll resubmit.

Also, the first patch set was RFC, and you were the only one to submit
feedback to me.  :-/  So I figured submitting as an official patch for
feedback might get more attention.

And to reiterate what Auke asked, what did happen to the patches?  I see
things getting through the netdev mailing list, but they're not showing
up on www.spinics.net/lists/netdev.  Was it something I did when
sending, or did majordomo hiccup?

Thanks,

-PJ Waskiewicz
