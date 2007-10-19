From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix race between sk_filter reassign and sk_clone()
Date: Fri, 19 Oct 2007 00:52:45 -0700 (PDT)
Message-ID: <20071019.005245.77429272.davem@davemloft.net>
References: <20071019022947.GA29560@lixom.net>
	<20071018.215521.28810637.davem@davemloft.net>
	<47185E9E.1030102@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, netdev@vger.kernel.org, devel@openvz.org,
	linux-kernel@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750916AbXJSHwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 03:52:32 -0400
In-Reply-To: <47185E9E.1030102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 11:37:02 +0400

> David Miller wrote:
> > From: Olof Johansson <olof@lixom.net>
> > Date: Thu, 18 Oct 2007 21:29:47 -0500
> > 
> >> So, looks like rcu_dereference() returned NULL. I don't know the
> >> filter code at all, but it seems like it might be a valid case?
> >> sk_detach_filter() seems to handle a NULL sk_filter, at least.
> >>
> >>
> >> So, this needs review by someone who knows the filter, but it fixes the
> >> problem for me:
> 
> Yes. The NULL filter is a valid case, when there are no
> filters attached at all. So this fix is correct.
> 
> Thanks, Olof. Sorry, Dave :(

No worries, thanks for reviewing.
