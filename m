From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] wext: reduce inline abuse
Date: Thu, 26 Apr 2007 14:37:01 -0700 (PDT)
Message-ID: <20070426.143701.131919386.davem@davemloft.net>
References: <20070426165032.GB22576@bougret.hpl.hp.com>
	<200704261903.27932.mb@bu3sch.de>
	<20070426171517.GA22667@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755143AbXDZVgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:36:54 -0400
In-Reply-To: <20070426171517.GA22667@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Tourrilhes <jt@hpl.hp.com>
Date: Thu, 26 Apr 2007 10:15:17 -0700

> On Thu, Apr 26, 2007 at 07:03:27PM +0200, Michael Buesch wrote:
> > 
> > Sure, other people have different opinions on that, but I think
> > with my approach we get smallest code with good speed.
> 
> 	Try with gcc-3.3 if you don't trust me. Your patch will
> produce bigger and slower code. Thanks.

A broken compiler is not an argument for keeping all of these
bogus inlines around.

It is the compilers job to optimize things correctly, and current
gcc's do.

We've always had this approach to dealing with compiler "issues".
